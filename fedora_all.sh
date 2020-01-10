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
${SCRIPT_DIR}/update_fedora_repodb.sh -v 29 $1/public_html/pub/Linux/Fedora
${SCRIPT_DIR}/update_fedora_repodb.sh -v 30 $1/public_html/pub/Linux/Fedora
${SCRIPT_DIR}/update_fedora_repodb.sh -v 31 $1/public_html/pub/Linux/Fedora
