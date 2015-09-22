#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$0"))

for unittest in $(find ${TESTDIR} -name *_test.sh); do
    echo "************ Run unit test ************"
    echo "test file: $unittest"
    echo "***************************************"
    $unittest
    echo "*************** Done... ***************"
    echo ""
done