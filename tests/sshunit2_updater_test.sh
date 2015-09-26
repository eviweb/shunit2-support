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
testSshunit2ShouldApplyUpdatesToAnOldTestFile()
{
    local project_dir="${HOME}/myproject"

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests"
    ${SSHUNIT2} -U "${project_dir}/tests/simple_test.sh"
    assertNotSame "the two files should be different" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${project_dir}/tests/simple_test.sh)"
}

testSshunit2ShouldTagAnUpdatedTestFileWithCurrentVersion()
{
    local project_dir="${HOME}/myproject"

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests"
    ${SSHUNIT2} -U "${project_dir}/tests/simple_test.sh"
    version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test file is tagged with current version" "grep -Poe '^# version: ${version}' ${project_dir}/tests/simple_test.sh"
}

testSshunit2ShouldApplyUpdatesToManyOldTestFilesFromAGivenDirectory()
{
    local project_dir="${HOME}/myproject"

    fakeProjectDir "${project_dir}"
    mkdir "${project_dir}/tests/folder"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests/s1_test.sh"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests/folder/s2_test.sh"
    ${SSHUNIT2} -U "${project_dir}/tests"
    assertNotSame "s1_test should have changed" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${project_dir}/tests/s1_test.sh)"
    assertNotSame "s2_test should have changed" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${project_dir}/tests/folder/s2_test.sh)"
}

testSshunit2ShouldNotUpdateCurrentVersionTestFile()
{
    local project_dir="${HOME}/myproject"
    local curversion="$(cat ${MAINDIR}/VERSION)"
    local originfile=$(cat ${TESTDIR}/fixtures/vcurrent_test.sh | sed "s/{{version}}/$curversion/")

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/vcurrent_test.sh" "${project_dir}/tests"
    sed -i "s/{{version}}/$curversion/" ${project_dir}/tests/vcurrent_test.sh
    ${SSHUNIT2} -U "${project_dir}/tests/vcurrent_test.sh"
    assertSame "no changes should have been applied" "${originfile}" "$(cat ${project_dir}/tests/vcurrent_test.sh)"
}

testSshunit2ShouldOnlyApplyNeededUpdates()
{
    local project_dir="${HOME}/myproject"
    local curversion="$(cat ${MAINDIR}/VERSION)"
    local expected="$(cat ${TESTDIR}/fixtures/vcurrent_test.sh | sed s/{{version}}/$curversion/)"

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/v0.2.0_test.sh" "${project_dir}/tests/dummy_test.sh"
    ${SSHUNIT2} -U "${project_dir}/tests/dummy_test.sh"
    assertSame "only version should have been updated" "${expected}" "$(cat ${project_dir}/tests/dummy_test.sh)"
}

testSshunit2ShouldUpdateAnOldTestSuite()
{
    local project_dir="${HOME}/myproject"
    local oldtestsuite="${TESTDIR}/fixtures/oldtestsuite.sh"

    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    cp "${oldtestsuite}" "${project_dir}/tests/testsuite.sh"
    ${SSHUNIT2} -U "${project_dir}/tests"
    assertNotSame "the two files should be different" "$(cat ${oldtestsuite})" "$(cat ${project_dir}/tests/testsuite.sh)"
    cp "${oldtestsuite}" "${project_dir}/tests/testsuite.sh"
    ${SSHUNIT2} -U "${project_dir}/tests/testsuite.sh"
    assertNotSame "the two files should be different" "$(cat ${oldtestsuite})" "$(cat ${project_dir}/tests/testsuite.sh)"
}

testSshunit2ShouldTagAnUpdatedTestSuiteWithCurrentVersion()
{
    local project_dir="${HOME}/myproject"
    local oldtestsuite="${TESTDIR}/fixtures/oldtestsuite.sh"

    fakeProjectDir "${project_dir}"
    cd "${project_dir}"
    cp "${oldtestsuite}" "${project_dir}/tests/testsuite.sh"
    ${SSHUNIT2} -U "${project_dir}/tests/testsuite.sh"
    version="$(cat ${MAINDIR}/VERSION)"
    assertTrue "test file is tagged with current version" "grep -Poe '^# version: ${version}' ${project_dir}/tests/testsuite.sh"
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