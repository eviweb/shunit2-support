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
    local expected_message="The target directory already exists"
    project_dir="${HOME}/myproject"
    mkdir -p "${project_dir}"
    ${SSHUNIT2} -p "${project_dir}" >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldEnableShunit2SupportInANonGitDirectory()
{
    local project_dir="${HOME}/myproject"
    mkdir -p "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -i >${FSTDOUT} 2>${FSTDERR}
    assertTrue "git init was run" "[[ '$(cat ${FSTDOUT})' =~ '.git' ]]"
    assertTrue "the project should contain the shunit2 library" "[ -e ${HOME}/myproject/lib/shunit2/source/2.1/src/shunit2 ]"
    assertTrue "shunit2 is set as a submodule" "[ -e ${HOME}/myproject/.gitmodules ] && grep shunit2 ${HOME}/myproject/.gitmodules &> /dev/null"
}

testSshunit2ShouldEnableShunit2SupportInAGitDirectory()
{
    local project_dir="${HOME}/myproject"
    mkdir -p "${project_dir}"
    cd "${project_dir}"
    git init -q
    ${SSHUNIT2} -i >${FSTDOUT} 2>${FSTDERR}
    assertFalse "git init was not run" "[[ '$(cat ${FSTDOUT})' =~ '.git' ]]"
    assertTrue "the project should contain the shunit2 library" "[ -e ${HOME}/myproject/lib/shunit2/source/2.1/src/shunit2 ]"
    assertTrue "shunit2 is set as a submodule" "[ -e ${HOME}/myproject/.gitmodules ] && grep shunit2 ${HOME}/myproject/.gitmodules &> /dev/null"
}

testSshunit2ShouldCreateATestFile()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -t "cmd"
    assertTrue "the test file was generated" "[ -e ${project_dir}/tests/cmd_test.sh ]"
    assertTrue "the test file is executable" "[ -x ${project_dir}/tests/cmd_test.sh ]"
}

testSshunit2ShouldCreateATestFileInSubfolder()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -t "folder/cmd"
    assertTrue "the subfolder was created" "[ -e ${project_dir}/tests/folder ]"
    assertTrue "the test file was generated in the subfolder" "[ -e ${project_dir}/tests/folder/cmd_test.sh ]"
}

testSshunit2ShouldCreateALibFile()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -l "folder/mylib"
    assertTrue "the library file was generated" "[ -e ${project_dir}/src/folder/mylib.sh ]"
    assertFalse "the test file is not executable" "[ -x ${project_dir}/src/folder/mylib.sh ]"
}

testSshunit2ShouldCreateACommandFile()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -c "folder/mycmd"
    assertTrue "the library file was generated" "[ -e ${project_dir}/src/folder/mycmd.sh ]"
    assertTrue "the test file is executable" "[ -x ${project_dir}/src/folder/mycmd.sh ]"
}

testEnsureGeneratedCommandAndLibFilesGetTheBashShebang()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -l "mylib"
    ${SSHUNIT2} -c "mycmd"
    assertTrue "the library file has the bash shebang" "grep '#! /bin/bash' ${project_dir}/src/mylib.sh"
    assertTrue "the command file has the bash shebang" "grep '#! /bin/bash' ${project_dir}/src/mycmd.sh"
}

# fix issue #1
testCommandOrLibFileNameShouldContainDots()
{
    local project_dir="${HOME}/myproject"
    local cmd="my.dotted.cmd"
    local lib="my.dotted.lib"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -l "${lib}"
    ${SSHUNIT2} -c "${cmd}"
    assertTrue "the library file exists" "[ -e ${project_dir}/src/${lib}.sh ]"
    assertTrue "the command file exists" "[ -e ${project_dir}/src/${cmd}.sh ]"
}

testSshunit2ShouldDieIfALibFileAlreadyExists()
{
    local expected_message="The file already exists, abort."
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    touch "src/mylib.sh"
    ${SSHUNIT2} -l "mylib" >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldDieIfACommandFileAlreadyExists()
{
    local expected_message="The file already exists, abort."
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    touch "src/mycmd.sh"
    ${SSHUNIT2} -l "mycmd" >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldDieIfNotInProjectDirWhenItIsRequired()
{
    local expected_message="Not in project directory, abort."
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${HOME}"
    #
    assertFalse "the script should exit with code 1" "${SSHUNIT2} -t cmd >${FSTDOUT} 2>${FSTDERR}"
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
    #
    assertFalse "the script should exit with code 1" "${SSHUNIT2} -l mylib >${FSTDOUT} 2>${FSTDERR}"
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
    #
    assertFalse "the script should exit with code 1" "${SSHUNIT2} -c mycmd >${FSTDOUT} 2>${FSTDERR}"
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
    #
    assertFalse "the script should exit with code 1" "${SSHUNIT2} -s >${FSTDOUT} 2>${FSTDERR}"
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testTheTestFileIsBuiltFromTemplates()
{
    local header=$(cat "${MAINDIR}/src/templates/header.tpl")
    local footer=$(cat "${MAINDIR}/src/templates/footer.tpl")

    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -t "cmd"
    local test_file=$(cat ${project_dir}/tests/cmd_test.sh)
    assertTrue "the test file contains the header part" "[[ '${test_file}' =~ '${header}' ]]"
    assertTrue "the test file contains the footer part" "[[ '${test_file}' =~ '${footer}' ]]"
}

testSshunit2ShouldCreateATestSuite()
{
    local suite=$(cat "${MAINDIR}/src/templates/suite.tpl")
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -s
    local suite_file="${project_dir}/tests/testsuite.sh"
    assertTrue "the test suite was generated" "[ -e ${suite_file} ]"
    assertTrue "the test suite is executable" "[ -x ${suite_file} ]"
    assertTrue "the test suite is made using the suite template" "[[ '$(cat ${suite_file})' =~ '${suite}' ]]"
}

testSshunit2ShouldInformUserIfATestSuiteAlreadyExists()
{
    local expected_message="A test suite runner already exists"
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    touch "${project_dir}/tests/testsuite.sh"
    cd "${project_dir}"
    ${SSHUNIT2} -s >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertEquals "the script should exit with code 1" 1 ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testSshunit2ShouldTagTestFilesWithCurrentVersion()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -t "cmd"
    local version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test file is tagged with current version" "grep -Poe '^# version: ${version}' ${project_dir}/tests/cmd_test.sh"
}

testSshunit2ShouldTagTestSuiteWithCurrentVersion()
{
    local project_dir="${HOME}/myproject"
    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    ${SSHUNIT2} -s
    local version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test suite is tagged with current version" "grep -Poe '^# version: ${version}' ${project_dir}/tests/testsuite.sh"
}

testSshunit2ShouldComplainIfTheCurrentDirectoryHasNotShunit2Enabled()
{
    local expected_message="Shunit2 support is not enabled in the current directory"
    local project_dir="${HOME}/myproject"
    mkdir -p ${project_dir}/{lib,src,tests}
    cd "${project_dir}"
    ${SSHUNIT2} -t "cmd" >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
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