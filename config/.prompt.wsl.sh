# Bash History Replacement Script
#    Author: Caesar Kabalan
#    Last Modified: June 6th, 2017
# Description:
#    Modifies the default Bash Shell prompt to be in the format of:
#       [CWD:COUNT:BRANCH:VENV]
#       [USER:HOSTNAME] _
#    Where:
#       CWD - Current working directory (green if last command returned 0, red otherwise)
#       COUNT - Session command count
#       BRANCH - Current git branch if in a git repository, omitted if not in a git repo
#       VENV - Current Python Virtual Environment if set, omitted if not set
#       USER - Current username
#       HOSTNAME - System hostname
#    Example:
#       [~/projects/losteyelid:8:master:losteyelid]
#       [ckabalan:spectralcoding] _
# Installation:
#    Add the following to one of the following files
#       System-wide Prompt Change:
#          /etc/profile.d/bash_prompt_custom.sh (new file)
#          /etc/bashrc
#       Single User Prompt Change:
#          ~/.bashrc
#          ~/.bash_profile

export PS0='$(date +"%s.%3N" > ~/.proc.start)'

__gp_color() {
  [ -n "$ZSH_VERSION" ] && echo -e "%{\e[$1m%}" || echo -e "\001\033[$1m\002"
}

__gp_status() {
  local COLOR_BRANCH=$(__gp_color "${GP_COLOR_GIT_BRANCH:-38;5;8}")
  local COLOR_STATUS=$(__gp_color "${GP_COLOR_GIT_STATUS:-38;5;9}")
  local COLOR_UNPUSHED=$(__gp_color "${GP_COLOR_GIT_UNPUSHED:-38;5;11}")
  local COLOR_RESET=$(__gp_color 0)
  local dir=${1:-.} branch unpushed state
  if branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null); then
    if git -C "$dir" rev-parse 2>/dev/null; then
      if ! unpushed=$(set -o pipefail; git -C "$dir" log origin/"$branch"..HEAD -- 2>/dev/null | head -c1 | if [ "$(wc -c)" -gt "0" ]; then echo "↑"; fi); then
        unpushed="•"
      fi
      state=$(set -o pipefail; git -C "$dir" status --porcelain 2>/dev/null | head -c1 | if [ "$(wc -c)" -gt "0" ]; then echo "✗"; fi)
    fi
    printf "%s⎇ %s%s%s%s%s%s" "${COLOR_BRANCH}" "${branch}" "${COLOR_STATUS}" "${state}" "${COLOR_UNPUSHED}" "${unpushed}" "${COLOR_RESET}"
  fi
}

set_bash_prompt () {
    local retc=$?
    local start=$(cat ~/.proc.start)
    local end=$(date +"%s.%3N")
    local epoc="$( echo | awk -v end="$end" -v start="$start" '{print end - start}')"
    local tsfmt="%H:%M:%S"

    #start=$(($start-(86400*3)))
    if expr $epoc '>' 86400 1>/dev/null ;then
        tsfmt="%d:%H:%M:%S"
    elif  expr $epoc '<' 60 1>/dev/null;then
        tsfmt="%S.%3Ns"
    fi

    local elap="$(date +"$tsfmt" -d@${epoc} -u)"

	local COLOR_DIVIDER="\[\e[30;1m\]"
	local COLOR_CMDCOUNT="\[\e[34;1m\]"
	local COLOR_USERNAME="\[\e[34;1m\]"
	local COLOR_USERHOSTAT="\[\e[34;1m\]"
	local COLOR_HOSTNAME="\[\e[34;1m\]"
	local COLOR_GITBRANCH="\[\e[33;1m\]"
	local COLOR_VENV="\[\e[33;1m\]"
	local COLOR_GREEN="\[\e[32;1m\]"
	local COLOR_PATH_OK="\[\e[32;1m\]"
	local COLOR_PATH_ERR="\[\e[31;1m\]"
	local COLOR_NONE="\[\e[0m\]"

	PS1="${COLOR_DIVIDER}[\D{%F %T}${COLOR_DIVIDER}|"

	if test $retc -eq 0 ; then
        PS1+="${COLOR_PATH_OK}\w${COLOR_DIVIDER}:${COLOR_CMDCOUNT}\!${COLOR_DIVIDER}"
	else
        PS1+="${COLOR_PATH_ERR}\w:${retc}${COLOR_DIVIDER}:${COLOR_CMDCOUNT}\!${COLOR_DIVIDER}"
	fi

	if ! git_loc="$(type -p "$git_command_name")" || [ -z "$git_loc" ]; then
		if [ -d .git ] || git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
			GIT_BRANCH=$(__git_ps1 "(%s)") #$(__gp_status)#$(git symbolic-ref --short HEAD)
			PS1="${PS1}:${COLOR_GITBRANCH}${GIT_BRANCH}${COLOR_DIVIDER}"
		fi
	fi

	if ! test -z "$VIRTUAL_ENV" ; then
		PS1="${PS1}:${COLOR_VENV}`basename \"$VIRTUAL_ENV\"`${COLOR_DIVIDER}"
	fi

    PS1+="|$elap"
	PS1="${PS1}]\n${COLOR_DIVIDER}[${COLOR_USERNAME}\u${COLOR_USERHOSTAT}@${COLOR_HOSTNAME}\h${COLOR_DIVIDER}]${COLOR_NONE} "
}

export PROMPT_COMMAND=set_bash_prompt
