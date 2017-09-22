#!/bin/bash

<<MISC
Author       : waqask
Email	     : waqas.khan@trueex.com
Version      : 0.1

Created      : 2017-02-08 15:08
Last Modified: 2017-02-08 15:09:18 UTC

Host Machine : r1-tome

Description  : 
MISC

TEST=0
DEBUG=0

function err_exit(){
    exit_code=$1
    shift
    echo "$@" > /dev/null >&2
}

function _log(){
    MSG=$2
    LVL=$1
    echo -e "$(date +"%Y-%m-%d %H:%M:%S.%3N")\t${LVL}\t${MSG}"
}

function show_help(){
    cat << HELP

Usage: ${BASH_SOURCE[0]} [options]

options:
    -h, --help           Show this help.
    --test               Enable test mode.
HELP
}


function parse_args() 
{
    while [[ $# -gt 0 ]]; do
        opt="$1"
        shift

        case "$opt" in
            -h|\?|--help)
                show_help
                exit 0
                ;;
            --test)
                TEST=$1
                shift
                ;;
       esac
    done
}


function main(){
        (grep -q "^flags.*\ hypervisor" /proc/cpuinfo && echo "This machine is a VM"^C) || echo "This machine is not a VM"
}

parse_args $*
main
