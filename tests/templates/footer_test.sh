#! /bin/bash
TESTDIR=$(dirname $(dirname $(readlink -f "$BASH_SOURCE")))
MAINDIR=$(dirname "${TESTDIR}")
SHUNIT2="${MAINDIR}/lib/shunit2/source/2.1/src/shunit2"
SSHUNIT2="${MAINDIR}/src/sshunit2"
FOOTER="${MAINDIR}/src/templates/footer.tpl"

if [ ! -e "${SHUNIT2}" ]; then
    echo "Abort: Shunit2 lib not found at: ${SHUNIT2}"
    exit 1
fi

. "${TESTDIR}/lib/func.sh"
################ Unit tests ################
testFooterTemplateFindShunit2ShouldFindShunit2Library()
{
    project_dir="${HOME}/myproject"
    test_dir="${project_dir}/tests"
    test_file="${test_dir}/test.sh"
    fakeProjectDir "${project_dir}"
    mkdir -p "${test_dir}"
    cd "${project_dir}"    
    cat ${FOOTER} > "${test_file}" && chmod +x "${test_file}"
    sed -i "s/^.*source\/2.1\/src\/shunit2/echo \$path/" "${test_file}"
    "${test_file}" >${FSTDOUT} 2>${FSTDERR}
    assertSame "\$path variable localizes correctly the shunit2 library" "${HOME}/myproject/lib/shunit2" "$(cat ${FSTDOUT})"
}

testFooterTemplateFindShunit2ShouldFindShunit2LibraryEvenInDeepSubfolder()
{
    project_dir="${HOME}/myproject"
    test_dir="${project_dir}/tests/subfolder"
    test_file="${test_dir}/test.sh"
    fakeProjectDir "${project_dir}"
    mkdir -p "${test_dir}"
    cd "${project_dir}"    
    cat ${FOOTER} > "${test_file}" && chmod +x "${test_file}"
    sed -i "s/^.*source\/2.1\/src\/shunit2/echo \$path/" "${test_file}"
    "${test_file}" >${FSTDOUT} 2>${FSTDERR}
    assertSame "\$path variable localizes correctly the shunit2 library" "${HOME}/myproject/lib/shunit2" "$(cat ${FSTDOUT})"
}

testFooterTemplateFindShunit2ShouldThrowAnErrorIfShunit2LibraryIsNotFound()
{
    expected_message="Error Shunit2 not found !"
    project_dir="${HOME}/myproject"
    test_dir="${project_dir}/tests/"
    test_file="${test_dir}/test.sh"
    mkdir -p "${test_dir}"
    cd "${project_dir}"    
    cat ${FOOTER} > "${test_file}" && chmod +x "${test_file}"
#    sed -i "s/^.*source\/2.1\/src\/shunit2/echo \$path/" "${test_file}"
    "${test_file}" >${FSTDOUT} 2>${FSTDERR}
#    echo "$(cat ${FSTDOUT})"
    exit_code=$?
    assertNotEquals "the script should exit with code other than 0, got: ${exit_code}" 0 ${exit_code}
    assertSame "the following message should be displayed: ${expected_message}" "${expected_message}" "$(cat ${FSTDERR})"
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