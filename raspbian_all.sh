#!/bin/bash

usage()
{
    cat <<EOF
    Usage:
    
    $(basename ${0}) /home/staging 
    $(basename ${0}) /home/openrtm 
EOF
}
if test $# -eq 0 ; then
    usage
    exit
fi
SCRIPT_DIR=$(cd $(dirname  $0); pwd)
${SCRIPT_DIR}/update_raspbian_repodb.sh -f -d bullseye $1/public_html/pub/Linux/raspbian
${SCRIPT_DIR}/update_raspbian_repodb.sh -f -d bookworm $1/public_html/pub/Linux/raspbian
