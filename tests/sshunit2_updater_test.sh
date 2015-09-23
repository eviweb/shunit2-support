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
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cp "${TESTDIR}/fixtures/simple_test.sh" "${maindir}/tests"
    ${SSHUNIT2} -U "${maindir}/tests/simple_test.sh"
    assertNotSame "the two files should be different" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${maindir}/tests/simple_test.sh)"
}

testSshunit2ShouldApplyUpdatesToManyOldTestFilesFromAGivenDirectory()
{
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    mkdir "${maindir}/tests/folder"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${maindir}/tests/s1_test.sh"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${maindir}/tests/folder/s2_test.sh"
    ${SSHUNIT2} -U "${maindir}/tests"
    assertNotSame "s1_test should have changed" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${maindir}/tests/s1_test.sh)"
    assertNotSame "s2_test should have changed" "$(cat ${TESTDIR}/fixtures/simple_test.sh)" "$(cat ${maindir}/tests/folder/s2_test.sh)"
}

testSshunit2ShouldNotUpdateCurrentVersionTestFile()
{
    local maindir="${HOME}/myproject"
    local curversion="$(cat ${MAINDIR}/VERSION)"
    local originfile=$(cat ${TESTDIR}/fixtures/vcurrent_test.sh | sed "s/{{version}}/$curversion/")

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cp "${TESTDIR}/fixtures/vcurrent_test.sh" "${maindir}/tests"
    sed -i "s/{{version}}/$curversion/" ${maindir}/tests/vcurrent_test.sh
    ${SSHUNIT2} -U "${maindir}/tests/vcurrent_test.sh"
    assertSame "no changes should have been applied" "${originfile}" "$(cat ${maindir}/tests/vcurrent_test.sh)"
}

testSshunit2ShouldUpdateAnOldTestSuite()
{
    local maindir="${HOME}/myproject"
    local oldtestsuite="${TESTDIR}/fixtures/oldtestsuite.sh"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cd "${maindir}"
    cp "${oldtestsuite}" "${maindir}/tests/testsuite.sh"
    ${SSHUNIT2} -U "${maindir}/tests"
    assertNotSame "the two files should be different" "$(cat ${oldtestsuite})" "$(cat ${maindir}/tests/testsuite.sh)"
    cp "${oldtestsuite}" "${maindir}/tests/testsuite.sh"
    ${SSHUNIT2} -U "${maindir}/tests/testsuite.sh"
    assertNotSame "the two files should be different" "$(cat ${oldtestsuite})" "$(cat ${maindir}/tests/testsuite.sh)"
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