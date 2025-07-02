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
${SCRIPT_DIR}/update_ubuntu_repodb.sh -f -d jammy $1/public_html/pub/Linux/ubuntu
${SCRIPT_DIR}/update_ubuntu_repodb.sh -f -d noble $1/public_html/pub/Linux/ubuntu
