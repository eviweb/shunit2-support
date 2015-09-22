#! /bin/bash
TESTDIR=$(dirname $(dirname $(readlink -f "$0")))
MAINDIR=$(dirname "${TESTDIR}")
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"
HEADER="${MAINDIR}/src/templates/header.tpl"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"
################ Unit tests ################
testHeaderTemplateShouldProvideDIRVariable()
{
    cat ${HEADER} > ${HOME}/test.sh && chmod +x ${HOME}/test.sh
    echo "echo \$DIR" >> ${HOME}/test.sh
    ${HOME}/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "\$DIR variable contains the correct path" "${HOME}" "$(cat ${FSTDOUT})"
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