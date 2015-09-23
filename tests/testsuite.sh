#! /bin/bash
TESTDIR=$(dirname $(readlink -f "$BASH_SOURCE"))
MAINDIR=$(dirname "${TESTDIR}")

. "${MAINDIR}/src/templates/suite.tpl"
