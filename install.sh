#! /bin/bash
DIR=$(dirname $(readlink -f "$0"))
BINDIR="${HOME}/bin"
SSHUNIT2="${DIR}/src/sshunit2"
BASH_RELOAD=0
UNINSTALL=0

# installer usage
usage() {
    echo "
    Usage:
        ./install.sh [OPTIONS]
    Options:
        -u      uninstall shunit2 support command
        -h      display this message
    Install/uninstall shunit2 support command
"
}

# perform the installation
install()
{
    if [ ! -e "${BINDIR}" ]; then
        mkdir -p "${BINDIR}" &> /dev/null
        if [ $? -ne 0 ]; then
            echo "failed to create ${BINDIR} directory, abort..." >&2
            exit 1
        fi
        BASH_RELOAD=1
    fi

    if [ ! -e "${BINDIR}/${SSHUNIT2##*/}" ]; then
        ln -s "${SSHUNIT2}" "${BINDIR}"
    else
        echo "A symlink to $(readlink -f ${BINDIR}/${SSHUNIT2##*/}) already exists, abort..." >&2
        exit 1
    fi

    if ((${BASH_RELOAD})); then
        echo "You will need to reload your bash environment: ie. 'exec bash -l'"
    fi
}

# perform the uninstallation
uninstall()
{
    checklink
    unlink ${BINDIR}/${SSHUNIT2##*/}
}

# check if the candidate link to be removed is the right one
checklink()
{
    if [ "$(readlink -f ${BINDIR}/${SSHUNIT2##*/})" != "${SSHUNIT2}" ]; then
        echo "fails to remove ${BINDIR}/${SSHUNIT2##*/} as it does not point to ${SSHUNIT2}, abort..." >&2
        exit 1
    fi
}

OPTIONS=":hu"
# get command line options
while getopts $OPTIONS option
do
    case $option in
        u) UNINSTALL=1;;
        *) usage && exit 1;;
    esac
done
shift $(($OPTIND - 1 ))

if ((${UNINSTALL})); then
    uninstall
else
    install
fi