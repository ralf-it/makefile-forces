#!/usr/bin/env bash

set -xeuo pipefail


function INFO {
    true
}

INFO Install and import forces.mk - BEGIN

mkdir -p .make

VERSION=${1:-main}

INFO Downloading forces.mk version: ${VERSION}

curl \
-H 'Cache-Control: no-cache' \
-s https://raw.githubusercontent.com/ralf-it/makefile-forces/${VERSION}/.make/forces.mk \
-o .make/forces.mk

INFO Check if Makefile exists
if [ -f Makefile ];
then
    M_EXISTS="true"
else
    M_EXISTS="false"
fi

INFO Check if Makefile already includes forces.mk
if [ "$M_EXISTS" == "true" ];
then
    if grep -q 'include .make/forces.mk' Makefile;
    then
        exit 0
    fi
fi

INFO Backup Makefile if exists
if [ "$M_EXISTS" == "true" ];
then
    cp Makefile "Makefile.$(date '+%Y%m%dT%H%M%S')"
fi

INFO Include forces.mk in Makefile

touch Makefile
OLD_MAKEFILE=$(cat Makefile)

cat <<EOF > Makefile
######### Makefile Forces #########
-include .make/forces.mk
###################################

${OLD_MAKEFILE}
EOF

INFO make/forces.mk installed and imported in Makefile - END
