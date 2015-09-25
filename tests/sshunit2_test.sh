#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$BASH_SOURCE"))
MAINDIR=$(dirname "${TESTDIR}")
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"
########### Tests ###########
testSshunit2ShouldCreateAProjectStructure()
{
    ${SSHUNIT2} -p "${HOME}/myproject" &> /dev/null
    assertTrue "create the project main directory at: ${HOME}/myproject" "[ -e ${HOME}/myproject ]"
    assertTrue "a src directory was created" "[ -e ${HOME}/myproject/src ]"
    assertTrue "a tests directory was created" "[ -e ${HOME}/myproject/tests ]"
    assertTrue "the project should contain the shunit2 library" "[ -e ${HOME}/myproject/lib/shunit2/source/2.1/src/shunit2 ]"
    assertTrue "shunit2 is set as a submodule" "[ -e ${HOME}/myproject/.gitmodules ] && grep shunit2 ${HOME}/myproject/.gitmodules &> /dev/null"
}

testSshunit2ShouldComplainIfATargetDirectoryAlreadyExists()
{
    expected_message="The target directory already exists"
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}"
    ${SSHUNIT2} -p "${target_dir}" >${FSTDOUT} 2>${FSTDERR}
    exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldEnableShunit2SupportInANonGitDirectory()
{
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}"
    cd "${target_dir}"
    ${SSHUNIT2} -i >${FSTDOUT} 2>${FSTDERR}
    assertTrue "git init was run" "[[ '$(cat ${FSTDOUT})' =~ '.git' ]]"
    assertTrue "the project should contain the shunit2 library" "[ -e ${HOME}/myproject/lib/shunit2/source/2.1/src/shunit2 ]"
    assertTrue "shunit2 is set as a submodule" "[ -e ${HOME}/myproject/.gitmodules ] && grep shunit2 ${HOME}/myproject/.gitmodules &> /dev/null"
}

testSshunit2ShouldEnableShunit2SupportInAGitDirectory()
{
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}"
    cd "${target_dir}"
    git init -q
    ${SSHUNIT2} -i >${FSTDOUT} 2>${FSTDERR}
    assertFalse "git init was not run" "[[ '$(cat ${FSTDOUT})' =~ '.git' ]]"
    assertTrue "the project should contain the shunit2 library" "[ -e ${HOME}/myproject/lib/shunit2/source/2.1/src/shunit2 ]"
    assertTrue "shunit2 is set as a submodule" "[ -e ${HOME}/myproject/.gitmodules ] && grep shunit2 ${HOME}/myproject/.gitmodules &> /dev/null"
}

testSshunit2ShouldCreateATestFile()
{
    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -t "cmd"
    assertTrue "the test file was generated" "[ -e ${target_dir}/tests/cmd_test.sh ]"
    assertTrue "the test file is executable" "[ -x ${target_dir}/tests/cmd_test.sh ]"
}

testSshunit2ShouldCreateATestFileInSubfolder()
{
    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -t "folder/cmd"
    assertTrue "the subfolder was created" "[ -e ${target_dir}/tests/folder ]"
    assertTrue "the test file was generated in the subfolder" "[ -e ${target_dir}/tests/folder/cmd_test.sh ]"
}

testSshunit2ShouldCreateALibFile()
{
    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -l "folder/mylib"
    assertTrue "the library file was generated" "[ -e ${target_dir}/src/folder/mylib.sh ]"
    assertFalse "the test file is not executable" "[ -x ${target_dir}/src/folder/mylib.sh ]"
}

testTheTestFileIsBuiltFromTemplates()
{
    header=$(cat "${MAINDIR}/src/templates/header.tpl")
    footer=$(cat "${MAINDIR}/src/templates/footer.tpl")

    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -t "cmd"
    test_file=$(cat ${target_dir}/tests/cmd_test.sh)
    assertTrue "the test file contains the header part" "[[ '${test_file}' =~ '${header}' ]]"
    assertTrue "the test file contains the footer part" "[[ '${test_file}' =~ '${footer}' ]]"
}

testSshunit2ShouldCreateATestSuite()
{
    suite=$(cat "${MAINDIR}/src/templates/suite.tpl")
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}"
    cd "${target_dir}"
    ${SSHUNIT2} -s
    suite_file="${target_dir}/tests/testsuite.sh"
    assertTrue "the test suite was generated" "[ -e ${suite_file} ]"
    assertTrue "the test suite is executable" "[ -x ${suite_file} ]"
    assertTrue "the test suite is made using the suite template" "[[ '$(cat ${suite_file})' =~ '${suite}' ]]"
}

testSshunit2ShouldInformUserIfATestSuiteAlreadyExists()
{
    expected_message="A test suite runner already exists"
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}/tests"
    touch "${target_dir}/tests/testsuite.sh"
    cd "${target_dir}"
    ${SSHUNIT2} -s >${FSTDOUT} 2>${FSTDERR}
    exit_code=$?
    assertEquals "the script should exit with code 1" 1 ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldTagTestFilesWithCurrentVersion()
{
    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -t "cmd"
    version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test file is tagged with current version" "grep -Poe '^# version: ${version}' ${target_dir}/tests/cmd_test.sh"
}

testSshunit2ShouldTagTestSuiteWithCurrentVersion()
{
    target_dir="${HOME}/myproject"
    ${SSHUNIT2} -p "${target_dir}" &> /dev/null
    cd "${target_dir}"
    ${SSHUNIT2} -s
    version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test suite is tagged with current version" "grep -Poe '^# version: ${version}' ${target_dir}/tests/testsuite.sh"
}

testSshunit2ShouldComplainIfTheCurrentDirectoryHasNotShunit2Enabled()
{
    expected_message="Shunit2 support is not enabled in the current directory"
    target_dir="${HOME}/myproject"
    mkdir -p "${target_dir}"
    cd "${target_dir}"
    ${SSHUNIT2} -t "cmd" >${FSTDOUT} 2>${FSTDERR}
    exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldDisplayUsageWhenUsingHFlag()
{
    ${SSHUNIT2} -h >${FSTDOUT} 2>${FSTDERR}
    assertNotNull "expects an usage output" "$(cat ${FSTDOUT})"
    assertNull "no error message should be displayed but got: $(cat ${FSTDERR})" "$(cat ${FSTDERR})"
}

testSshunit2ShouldDisplayUsageWhenUsingWrongFlag()
{
    ${SSHUNIT2} -z >${FSTDOUT} 2>${FSTDERR}
    assertNotNull "expects an usage output" "$(cat ${FSTDOUT})"
    assertNull "no error message should be displayed but got: $(cat ${FSTDERR})" "$(cat ${FSTDERR})"
}

###### Setup / Teardown #####
oneTimeSetUp()
{
    newTestDir
    assertTrue 'fails to create a temp directory for testing' "[ -e ${SSHUNIT2_TEMPDIR} ]"
    newHomeDir "${SSHUNIT2_TEMPDIR}"
}

oneTimeTearDown()
{
    cleanTestDir
    assertTrue 'fails to remove the temp directory' "[ ! -e ${SSHUNIT2_TEMPDIR} ]"
    revertHomeDir
}

setUp()
{    
    OLDPWD="$PWD"
    prepareTestEnvironment
}

tearDown()
{
    cd "$OLDPWD"
}

########## Shunit2 ##########
. "${SHUNIT2}"