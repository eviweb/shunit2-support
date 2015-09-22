#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$0"))
MAINDIR=$(dirname "${TESTDIR}")

. "${MAINDIR}/src/templates/suite.tpl"
