#!/bin/bash

<<MISC
Author       : waqask
Email	     : waqas.khan@trueex.com
Version      : 0.1

Created      : 2017-08-14 08:01
Last Modified: 2017-09-18 13:34:02 UTC

Host Machine : r1-tome

Description  : 
MISC

TEST=0
DEBUG=0

DATE=$(date +"%m/.*/%Y")
ALLOWED=('AMQ9410' 'AMQ9545' 'AMQ9533' 'AMQ9001' 'AMQ9002')
NOFILTER="0"
AMQCODE=""

DO_DETAILS=0

WSMQBOX="$(facts.sh -e prod -f acmq_lch_host | cut -d'=' -f2)"
WSMQLCHLOG="/var/mqm/qmgrs/TEX\!IRS\!PROD\!LCH/errors/AMQERR01.LOG"

declare -A colors;
colors=(\
    ['black']='\E[0;47m'\
    ['red']='\E[0;31m'\
    ['error']='\E[0;31m'\
    ['green']='\E[0;32m'\
    ['yellow']='\E[0;33m'\
    ['debug']='\E[0;33m'\
    ['blue']='\E[0;34m'\
    ['magenta']='\E[0;35m'\
    ['cyan']='\E[0;36m'\
    ['white']='\E[0;37m'\
    ['reset']='\E[0;00m'\
)

function _log(){
    LVL="${1^^}"
    MSG=$2

    (test "$DEBUG" == "0" && test "$LVL" == "DEBUG") && return 0
    test -t 1 && LVL="${colors[${LVL,,}]}${LVL}${colors['reset']}"

    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S.%3N %z")\t${LVL}\t${MSG}"
}

function show_help(){
    cat << HELP

Usage: ${BASH_SOURCE[0]} [options]

options:
    -h, --help           Show this help.
    --test               Enable test mode.
    --debug              Enable debug logging.
    -d, --date           dd/mm/yyyy - BRE supported
    -n,--no-filter       Disables filtering known error codes
    --details            Displays full log messages for today or date using -d

HELP
}


function parse_args() 
{
    if [[ "$#" == "0" && "$DEBUG" == "1" ]];then
        show_help
        exit 0
    fi

    while [[ $# -gt 0 ]]; do
        opt="$1"
        shift

        case "$opt" in
            -h|\?|--help)
                show_help
                exit 0
                ;;
            --test)
                TEST="1"
                ;;
            --debug)
                DEBUG="1"
                ;;
            -d|--date)
                DATE="$1"
                shift
                ;;
            -n|--no-filter)
                NOFILTER="1"
                ;;
            -c|--code)
                AMQCODE="${1^^}"
                shift
                ;;
            --detail|--details)
                DO_DETAILS=1
                ;;
       esac
    done
}

function get_code_details(){
    _log "debug" "$AMQCODE"
    curl "https://www.ibm.com/support/knowledgecenter/SSFKSJ_8.0.0/com.ibm.mq.ref.doc/amq9.htm?view=embed" |& grep "$AMQCODE" -A7| sed -e 's/<[^>]*>//g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g'
}

function get_log_details(){
    WSLINES="$(ssh -q chef "ssh -q $WSMQBOX \"sudo -u mqm sed -n '/${DATE//\//\\/}/,/----/p' $WSMQLCHLOG\"")"
    echo "$WSLINES"
}

function main(){
    if [[ "$AMQCODE" != "" ]];then
        get_code_details
        return
    elif [[ "$DO_DETAILS" == "1" ]];then
        get_log_details
        return
    fi

    WSLINES="$(ssh -q chef "ssh -q $WSMQBOX \"sudo -u mqm grep -B5 '^AMQ' $WSMQLCHLOG | grep -A5 '$DATE'\"")"

    #TODO: fix it so 2017 isnt hard coded but reads of DATE instead
    WSERRORS=$(echo "$WSLINES" | awk '{if ($1 ~ "/2017"){ets=$1"T"$2}else if ($1 ~ "^AMQ"){e=$1;$1="";errors[ets"\t"e]=$0}} END{for (e in errors){printf("%s %s\n",e,errors[e])}}' | sort -t'/' -k1n -k2n -k3)

    if [[ "$NOFILTER" == "0" ]];then
        echo "${WSERRORS[@]}" | grep -v "$(printf "%s\|" ${ALLOWED[@]}) | awk '{print substr($0,0,length($0)-1)}"
    else
        echo "${WSERRORS[@]}"
    fi
}

function cleanup(){
    echo ""
    _log "DEBUG" "Exiting.."
    exit 1
}

parse_args $*
trap cleanup INT
main
