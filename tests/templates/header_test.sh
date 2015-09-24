#! /bin/bash
TESTDIR=$(dirname $(dirname $(readlink -f "$BASH_SOURCE")))
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
testHeaderMeFunctionShouldReturnTheRealPathOfItsHostFile()
{
    cat ${HEADER} > ${HOME}/test.sh && chmod +x ${HOME}/test.sh
    echo "echo \$(me)" >> ${HOME}/test.sh
    ${HOME}/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "me() returns the expected path" "${HOME}/test.sh" "$(cat ${FSTDOUT})"
}

testHeaderMeFunctionShouldReturnTheRealPathOfItsHostFileWhenlinked()
{
    cat ${HEADER} > ${HOME}/test.sh && chmod +x ${HOME}/test.sh
    echo "echo \$(me)" >> ${HOME}/test.sh
    ln -s ${HOME}/test.sh ${HOME}/caller.sh
    ${HOME}/caller.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "me() returns the expected path" "${HOME}/test.sh" "$(cat ${FSTDOUT})"
}

testHeaderMeFunctionShouldReturnTheRealPathOfItsHostFileWhenSourced()
{
    cat ${HEADER} > ${HOME}/test.sh
    echo "echo \$(me)" >> ${HOME}/test.sh
    echo -e "#! /bin/bash\n. ${HOME}/test.sh" > ${HOME}/caller.sh && chmod +x ${HOME}/caller.sh
    ${HOME}/caller.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "me() returns the expected path" "${HOME}/test.sh" "$(cat ${FSTDOUT})"
}

testHeaderMyDirFunctionShouldReturnTheRealPathOfItsHostFile()
{
    cat ${HEADER} > ${HOME}/test.sh && chmod +x ${HOME}/test.sh
    echo "echo \$(mydir)" >> ${HOME}/test.sh
    ${HOME}/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "mydir() returns the expected path" "${HOME}" "$(cat ${FSTDOUT})"
}

testHeaderMyDirFunctionShouldReturnTheRealPathOfItsHostFileWhenlinked()
{
    cat ${HEADER} > ${HOME}/test.sh && chmod +x ${HOME}/test.sh
    echo "echo \$(mydir)" >> ${HOME}/test.sh
    ln -s ${HOME}/test.sh ${HOME}/caller.sh
    ${HOME}/caller.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "mydir() returns the expected path" "${HOME}" "$(cat ${FSTDOUT})"
}

testHeaderMyDirFunctionShouldReturnTheRealPathOfItsHostFileWhenSourced()
{
    cat ${HEADER} > ${HOME}/test.sh
    echo "echo \$(mydir)" >> ${HOME}/test.sh
    echo -e "#! /bin/bash\n. ${HOME}/test.sh" > ${HOME}/caller.sh && chmod +x ${HOME}/caller.sh
    ${HOME}/caller.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "mydir() returns the expected path" "${HOME}" "$(cat ${FSTDOUT})"
}

testHeaderMainDirFunctionShouldReturnTheRealPathOfTheProjectDirectory()
{
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    mkdir -p "${maindir}/tests/folder"
    cat ${HEADER} > ${maindir}/tests/test.sh && chmod +x ${maindir}/tests/test.sh
    cat ${HEADER} > ${maindir}/tests/folder/test.sh && chmod +x ${maindir}/tests/folder/test.sh
    echo "echo \$(maindir)" >> ${maindir}/tests/test.sh
    echo "echo \$(maindir)" >> ${maindir}/tests/folder/test.sh
    ${maindir}/tests/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "maindir() returns the main directory" "${maindir}" "$(cat ${FSTDOUT})"
    ${maindir}/tests/folder/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "maindir() returns the main directory" "${maindir}" "$(cat ${FSTDOUT})"
}

testHeaderSrcDirFunctionShouldReturnTheRealPathOfTheSourceDirectory()
{
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cat ${HEADER} > ${maindir}/tests/test.sh && chmod +x ${maindir}/tests/test.sh
    echo "echo \$(srcdir)" >> ${maindir}/tests/test.sh
    ${maindir}/tests/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "srcdir() returns the source directory" "${maindir}/src" "$(cat ${FSTDOUT})"
}

testHeaderTestDirFunctionShouldReturnTheRealPathOfTheTestDirectory()
{
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cat ${HEADER} > ${maindir}/tests/test.sh && chmod +x ${maindir}/tests/test.sh
    echo "echo \$(qatestdir)" >> ${maindir}/tests/test.sh
    ${maindir}/tests/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "qatestdir() returns the test directory" "${maindir}/tests" "$(cat ${FSTDOUT})"
}

testHeaderLibDirFunctionShouldReturnTheRealPathOfTheMainLibDirectory()
{
    local maindir="${HOME}/myproject"

    ${SSHUNIT2} -p "${maindir}" &> /dev/null
    cat ${HEADER} > ${maindir}/tests/test.sh && chmod +x ${maindir}/tests/test.sh
    echo "echo \$(libdir)" >> ${maindir}/tests/test.sh
    ${maindir}/tests/test.sh >${FSTDOUT} 2>${FSTDERR}
    assertSame "libdir() returns the main lib directory" "${maindir}/lib" "$(cat ${FSTDOUT})"
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