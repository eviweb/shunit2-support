#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$0"))
res=0

for unittest in $(find ${TESTDIR} -name *_test.sh); do
    echo "************ Run unit test ************"
    echo "test file: $unittest"
    echo "***************************************"
    $unittest
    ret=$?
    if [[ $res -eq 0 ]] && [[ $ret -eq 0 ]]; then
        res=0
    else
        res=1
    fi
    echo "*************** Done... ***************"
    echo ""
done

exit $res