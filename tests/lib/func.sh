#! /bin/bash
# provides some global variables:
#   - SSHUNIT2_TEMPDIR: temporary directory in which running tests
#   - OLDHOME: backup of the $HOME variable before its alteration
#   - FSTDOUT: standard output file
#   - FSTDERR: standard error file

# create a new temporary directory for running tests
newTestDir()
{
    SSHUNIT2_TEMPDIR=$(mktemp -d -t)
}

# remove the temporary test directory and all its content
cleanTestDir()
{
    if [ -e "${SSHUNIT2_TEMPDIR}" ]; then
        rm -rf "${SSHUNIT2_TEMPDIR}"
    fi
}

# ensure sanity of the test environment
prepareTestEnvironment()
{
    rm -rf ${SSHUNIT2_TEMPDIR}/*
    initOutputs
}

# alter the $HOME variable with a given path
# @param string $1 new path
newHomeDir()
{
    OLDHOME="${HOME}"
    HOME="$1"
}

# revert the $HOME value
revertHomeDir()
{
    HOME="${OLDHOME}"
}

# initialize output files
initOutputs()
{
    FSTDERR="${SSHUNIT2_TEMPDIR}/fstderr"
    FSTDOUT="${SSHUNIT2_TEMPDIR}/fstdout"

    echo > "${FSTDERR}"
    echo > "${FSTDOUT}"
}

# fake project directory
# @param string $1 project directory path
fakeProjectDir()
{
    local shunit2_src="lib/shunit2/source/2.1/src"
    local shunit2_mod='
[submodule "shunit2"]
    path = lib/shunit2
    url = https://github.com/kward/shunit2.git
'
    mkdir -p $1/{${shunit2_src},src,tests}
    touch $1/${shunit2_src}/shunit2
    echo "${shunit2_mod}" > $1/.gitmodules
}