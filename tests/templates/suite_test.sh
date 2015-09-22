#! /bin/bash
TESTDIR=$(dirname $(dirname $(readlink -f "$0")))
MAINDIR=$(dirname "${TESTDIR}")
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"
SUITE="${MAINDIR}/src/templates/suite.tpl"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"
################ Unit tests ################
testSuiteShouldSucceedByDefault()
{
    runTestSuite
    exit_code=$?
    assertEquals "default exit code should be 0" 0 ${exit_code}
}

testSuiteShouldFindAndRunATest()
{
    test1=$(newSuccessfulTest "test1")
    runTestSuite
    assertTrue "test was run and succeed" "[[ '$(cat ${FSTDOUT})' =~ 'testPassed' ]]"
    assertEquals "test filename is displayed" "${test1}" $(grep -o "${test1}" "${FSTDOUT}")
}

testSuiteShouldFindRecursivelyAndRunManyTests()
{
    test1=$(newSuccessfulTest "test1")
    test2=$(newSuccessfulTest "folder/test2")
    runTestSuite
    assertTrue "test was run and succeed" "[[ '$(cat ${FSTDOUT})' =~ 'testPassed' ]]"
    assertEquals "first test filename is displayed" "${test1}" $(grep -o "${test1}" "${FSTDOUT}")
    assertEquals "second test filename is displayed" "${test2}" $(grep -o "${test2}" "${FSTDOUT}")
}

testSuiteShouldSucceedWhenAllTestsSucceed()
{
    test1=$(newSuccessfulTest "test1")
    test2=$(newSuccessfulTest "test2")
    test3=$(newSuccessfulTest "test3")
    runTestSuite
    exit_code=$?
    assertEquals "default exit code should be 0" 0 ${exit_code}
    assertTrue "test suite should indicate all tests passed" "[[ '$(cat ${FSTDOUT})' =~ 'Test Suite PASSED' ]]"
    assertNull "unexpected error output" "$(cat ${FSTDERR})"
}

testSuiteShouldFailWhenAtLeastOneTestFails()
{
    test1=$(newSuccessfulTest "test1")
    test2=$(newFailureTest "test2")
    test3=$(newSuccessfulTest "test3")
    runTestSuite
    exit_code=$?
    assertEquals "default exit code should be 1" 1 ${exit_code}
    assertTrue "test suite should indicate at least one test failed" "[[ '$(cat ${FSTDERR})' =~ 'Test Suite FAILED' ]]"
}

testSuiteShouldDisplayTheNumberOfFailures()
{
    test1=$(newSuccessfulTest "test1")
    test2=$(newFailureTest "test2")
    test3=$(newFailureTest "test3")
    runTestSuite
    assertTrue "number of failures should be 2" "[[ '$(cat ${FSTDERR})' =~ 'Test Suite FAILED (failures=2)' ]]"
    test1=$(newSuccessfulTest "test1")
    test2=$(newSuccessfulTest "test2")
    test3=$(newFailureTest "test3")
    runTestSuite
    assertTrue "number of failures should be 1" "[[ '$(cat ${FSTDERR})' =~ 'Test Suite FAILED (failures=1)' ]]"
}

testSuiteShouldCollectFailingTestFile()
{
    test1=$(newSuccessfulTest "test1")
    test2=$(newFailureTest "test2")
    test3=$(newFailureTest "test3")
    runTestSuite
    error="$(cat ${FSTDERR})"
    assertTrue "failing test files should be collected" "[[ '${error}' =~ 'Failing Test Files' ]]"
    assertTrue "test2 should be listed" "[[ '${error}' =~ 'test2_test.sh' ]]"
    assertTrue "test3 should be listed" "[[ '${error}' =~ 'test3_test.sh' ]]"
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
    newTestSuite
}

tearDown()
{
    cd "$OLDPWD"
}

newTestSuite()
{
    cat ${SUITE} > ${HOME}/testsuite.sh && chmod +x ${HOME}/testsuite.sh
}

runTestSuite()
{
    ${HOME}/testsuite.sh >${FSTDOUT} 2>${FSTDERR}
}

newTestFile()
{
    local test_file="${HOME}/$1_test.sh"
    local test_dir=$(dirname "${test_file}")

    if [ ! -e "${test_dir}" ]; then
        mkdir -p "${test_dir}"
    fi

    touch "${test_file}" && chmod +x "${test_file}"

    echo "${test_file}"
}

newSuccessfulTest()
{
    local test_file=$(newTestFile "$1")
    cat << 'EOF' > "${test_file}"
echo "
testPassed

Ran 1 test.

OK
"
exit 0
EOF
    
    echo "${test_file}"
}

newFailureTest()
{
    local test_file=$(newTestFile "$1")
    cat << 'EOF' > "${test_file}"
echo "
testPassed
testFailed
ASSERT: an assertion message

Ran 2 tests.

FAILED (failures=1)
"
exit 1
EOF
    
    echo "${test_file}"
}

########## Shunit2 ##########
. "${SHUNIT2}"