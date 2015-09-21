################ RUN shunit2 ################
findShunit2()
{
    DIR=$(dirname $(readlink -f "$1"))
    while [ ! -e "${DIR}/lib/shunit2" ] && [ "${DIR}" != "/" ]; do
        DIR=$(dirname ${DIR})
    done

    if [ "${DIR}" == "/" ]; then
        echo "Error Shunit2 not found !"
        exit 1
    fi

    echo "${DIR}/lib/shunit2"
}

exitOnError()
{
    echo "$2"
    exit $1
}
#
path=$(findShunit2 "$0")
if [ $? -ne 0 ]; then
    exitOnError $? "${path}"
fi
. "${path}"/source/2.1/src/shunit2
#