#!/bin/bash

<<MISC
Author       : waqask
Email	     : waqas.khan@trueex.com
Version      : 0.1

Created      : 2017-03-24 07:59
Last Modified: 2017-09-13 08:52:41 UTC

Host Machine : r1-tome

Description  : 
MISC

TEST=0
DEBUG=0

FILES=""
DONT_DIFF=0

function err_exit(){
    exit_code=$1
    shift
    echo "$@" > /dev/null >&2
}

function _log(){
    MSG=$2
    LVL="${1^^}"
    echo -e "$(date +"%Y-%m-%d %H:%M:%S.%3N")\t${LVL}\t${MSG}"
}

function show_help(){
    cat << HELP

Usage: ${BASH_SOURCE[0]} [options]

options:
    -h, --help           Show this help.
    -f, --file           File to commit
HELP
}


function parse_args() 
{
    if [[ "$#" -lt "1" ]];then
        _log "ERROR" "Please provide some files"
        exit
    fi
    FILES=("$@")
}

git_pull(){
    git pull || return 1
}

git_stage(){
    git add "${FILES[@]}" || return 1
}

show_diff(){
    for FILE in "${FILES[@]}";do
        vimdiff $FILE +"Gdiff HEAD~"
    done

    echo -n "Attempt Commit?[y/n]:"
    read DOIT
    
    if [ "${DOIT^^}" == "Y" ]; then
        return 0
    else
        return 1
    fi
}

do_commit(){
    git commit || return 1
}

git_review(){
    REPO="$(pwd | cut -d'/' -f6)"
    HASH="$(git log | head -n1 | cut -d' ' -f2)"
    DIFF_URL="http://git.in.trueex.com/?p=${REPO}.git;a=commitdiff;h=${HASH};ds=sidebyside"
    COMM_MSG="$(git log | grep "^ " | head -n1)"

    echo -e "\tPlease review: $DIFF_URL\n\t\t$COMM_MSG"
}

do_checks(){
    local RETC=0

    for FILE in "${FILES[@]}";do
        if [[ "$(head -n1 $FILE | grep bash -c)" != "0" ]];then
            echo -e "\nRunning bash syntax checker [$FILE]..."
            #shellcheck -e SC1117 $FILE
            bash -n $FILE
            RETC=$?
        elif [[ "$(head -n1 $FILE | grep python -c)" != "0" ]];then
            echo -e "\nRunning python syntax checker [$FILE]..."
            python -m py_compile $FILE
            RETC=$?
        fi
    done

    return $RETC
}
function main(){
    if ! show_diff; then
        exit 0
    fi

    if ! do_checks; then
        echo -e "I said fix up!"
        exit 1
    fi

    if ! git_pull; then
        _log "ERROR" "Unable to do git pull"
        exit 1
    fi
    
    if ! git_stage; then
        _log "ERROR" "Unable to do git stage"
        exit 1
    fi

    if ! do_commit; then
        _log "ERROR" "Unable to do git commit"
        exit 1
    else
        git push origin
    fi

    git_review
}

parse_args $*
main
