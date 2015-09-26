#! /bin/bash
TESTDIR=$(dirname $(dirname $(readlink -f "$BASH_SOURCE")))
MAINDIR=$(dirname "${TESTDIR}")
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"
UPDATE="${MAINDIR}/src/updates/v0.2.0_update.sh"
HEADER="${MAINDIR}/src/templates/header.tpl"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"
########### Tests ###########
testV020UpdateShouldInsertLastHeaderAtTheTopOfAnOldTestFile()
{
    local project_dir="${HOME}/myproject"
    local header="$(cat ${HEADER})"
    local nlines=$(echo "${header}" | wc -l)

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests"
    ${SSHUNIT2} -U "${project_dir}/tests/simple_test.sh"
    assertSame "the header template should be inserted at the top of the old test file" "$(cat ${HEADER})" "$(head -n ${nlines} ${project_dir}/tests/simple_test.sh)"
}

testV020UpdateShouldFixDirVariableOfAnOldTestFile()
{
    local project_dir="${HOME}/myproject"
    local oldpattern='DIR=$(dirname $(readlink -f "$0"))'
    local newpattern='DIR="$(mydir)"'

    fakeProjectDir "${project_dir}"
    cp "${TESTDIR}/fixtures/simple_test.sh" "${project_dir}/tests"
    ${SSHUNIT2} -U "${project_dir}/tests/simple_test.sh"
    grep "${oldpattern}" ${project_dir}/tests/simple_test.sh >${FSTDOUT}
    assertNull "the DIR variable should have changed" "$(cat ${FSTDOUT})"
    assertSame "the DIR variable should now use mydir function" "${newpattern}" "$(grep ${newpattern} ${project_dir}/tests/simple_test.sh)"
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