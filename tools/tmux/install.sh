#!/bin/bash

<<MISC
Author       : waqask
Version      : 1.0

Created      : 2017-09-15 07:19
Last Modified: 2017-09-22 12:37:19 UTC

Description  : 
MISC

TEST=0
DEBUG=1
CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CNAME="$( basename "$0" )"

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

TMUX_VERSION="2.5"
LIBEVENT_VERSION="2.1.8"

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
                TEST="1"
                shift
                ;;
            --debug)
                DEBUG="1"
       esac
    done
}

function init(){
    cd "$CDIR"
    ls | grep "$CNAME" -v | xargs -i rm {}
}

function download_sources(){
    wget -O "tmux-${TMUX_VERSION}.tar.gz" "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
    wget "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz"
    wget "http://invisible-island.net/datafiles/release/ncurses.tar.gz"
}

function install_libevent(){
    tar -xvzf "libevent-${LIBEVENT_VERSION}-stable.tar.gz"
    cd "libevent-${LIBEVENT_VERSION}-stable"
    ./configure --prefix=$HOME/local --disable-shared
    make
    make install
    cd ..
}

function install_ncurses(){
    tar -xvzf ncurses.tar.gz
    cd ncurses-*
    ./configure --prefix=$HOME/local
    make
    make install
    cd ..
}

function install_tmux(){
    tar -xvzf "tmux-${TMUX_VERSION}.tar.gz"
    cd "tmux-${TMUX_VERSION}"
    ./configure CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"
    CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make
    cp tmux $HOME/bin
    cd ..
}

function main(){
    _log "DEBUG" "install.sh"
    init
    download_sources
    install_libevent
    install_ncurses
    install_tmux
}

function cleanup(){
    echo ""
    _log "DEBUG" "Exiting.."
    exit 1
}

parse_args $*
trap cleanup INT
main
