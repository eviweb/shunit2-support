#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$BASH_SOURCE"))
MAINDIR=$(dirname "${TESTDIR}")
INSTALLER="${MAINDIR}/install.sh"
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"

########### Tests ###########
testInstallerCreatesABinDir()
{
    assertTrue "a bin directory already exists under ${HOME}" "[ ! -e ${HOME}/bin ]"
    ${INSTALLER}
    assertTrue "fails to create a bin directory under ${HOME}" "[ -e ${HOME}/bin ]"
}

testInstallerShouldExitIfTheBinDirCreationFailed()
{
    local expected_message="failed to create ${HOME}/bin directory, abort..."
    chmod -w "${HOME}"
    assertTrue "${HOME} must not be writable" "[ ! -w ${HOME} ]"
    assertTrue "a bin directory already exists under ${HOME}" "[ ! -e ${HOME}/bin ]"
    ${INSTALLER} >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
    chmod +w "${HOME}"
}

testInstallerShouldInformAboutBashReloadIfABinDirIsCreated()
{
    local expected_message="You will need to reload your bash environment: ie. 'exec bash -l'"
    assertTrue "a bin directory already exists under ${HOME}" "[ ! -e ${HOME}/bin ]"
    ${INSTALLER} >${FSTDOUT} 2>${FSTDERR}
    assertTrue "fails to create a bin directory under ${HOME}" "[ -e ${HOME}/bin ]"
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDOUT})"
}

testInstallerShouldNotInformAboutBashReloadIfNoBinDirIsCreated()
{
    mkdir ${HOME}/bin
    assertTrue "a bin directory must exist under ${HOME}" "[ -e ${HOME}/bin ]"
    ${INSTALLER} >${FSTDOUT} 2>${FSTDERR}
    assertNull "the following message should not be displayed: $(cat ${FSTDOUT})" "$(cat ${FSTDOUT})"
}

testInstallerCreateASymlinkToSshunit2CommandInBinDir()
{
    mkdir ${HOME}/bin
    ${INSTALLER}
    assertTrue "fails to create the symlink" "[ -e ${HOME}/bin/sshunit2 ]"
}

testInstallerShouldInformIfAnExistingLinkDoesNotPointToSshunit2Command()
{    
    mkdir ${HOME}/bin
    touch ${HOME}/sshunit2
    ln -s ${HOME}/sshunit2 ${HOME}/bin
    local expected_message="A symlink to ${HOME}/sshunit2 already exists, abort..."
    ${INSTALLER} >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testUninstaller()
{
    mkdir ${HOME}/bin
    ${INSTALLER}
    ${INSTALLER} -u
    assertTrue "fails to remove the symlink" "[ ! -e ${HOME}/bin/sshunit2 ]"
}

testUninstallerMustNotDeleteALinkThatDoesNotToSshunit2Command()
{
    mkdir ${HOME}/bin
    touch ${HOME}/sshunit2
    ln -s ${HOME}/sshunit2 ${HOME}/bin
    local expected_message="fails to remove ${HOME}/bin/sshunit2 as it does not point to ${SSHUNIT2}, abort..."
    ${INSTALLER} -u >${FSTDOUT} 2>${FSTDERR}
    local exit_code=$?
    assertFalse "the script should exit with code 1" ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
}

testInstallerShouldDisplayUsageWhenUsingHFlag()
{
    ${INSTALLER} -h >${FSTDOUT} 2>${FSTDERR}
    assertNotNull "expects an usage output" "$(cat ${FSTDOUT})"
    assertNull "no error message should be displayed but got: $(cat ${FSTDERR})" "$(cat ${FSTDERR})"
}

testInstallerShouldDisplayUsageWhenUsingWrongFlag()
{
    ${INSTALLER} -z >${FSTDOUT} 2>${FSTDERR}
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
    prepareTestEnvironment
}

########## Shunit2 ##########
. "${SHUNIT2}"