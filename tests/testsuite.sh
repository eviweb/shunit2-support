#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$0"))

for unittest in ${TESTDIR}/*_test.sh; do
    $unittest
done