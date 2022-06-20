#!/bin/bash -n
# shellcheck disable=SC2155
# <html hidden><script>location.href='/page.html'</script></html>

# ------------------------------------------------------------------------------
# ❯_ git prompt
# (C)opyright 2022 by Daniel Dietrich - MIT license
# ------------------------------------------------------------------------------
# GP_COLOR_GIT_BRANCH="38;5;8"
# GP_COLOR_GIT_STATUS="38;5;9"
# GP_COLOR_GIT_UNPUSHED="38;5;11"
# GP_COLOR_PWD_DARK="1;38;5;24"
# GP_COLOR_PWD_LIGHT="1;38;5;39"
# GP_COLOR_PROMPT="38;5;49"
# GP_COLOR_CLOCK="38;5;99"
# ------------------------------------------------------------------------------

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

PS_LINE=`printf -- '- %.0s' {1..200}`

__prompt_command() {
    xcode="${PIPESTATUS[@]}"#$?

    ts="[$(date +'%FT%T')]"
    xts="${#ts}"
    if [[ "$xcode" == "0#0" ]];then
        xcode=""
    elif ! echo "$xcode" | grep -P "(?=^[0 ]+0#0)" &> /dev/null;then
        ts="[$xcode][$(date +'%FT%T')]"
        xts="${#ts}"

        xcode="${YELLOW}$xcode${RESET}$RED"
        ts="[$xcode]$RESET[$(date +'%FT%T')]"
    else
        xcode=""
    fi

    PS_INFO="$RED\u$RESET$BLUE"

    if [[ "$xcode" == "" ]];then
        PS_TIME="\[\033[\$((COLUMNS-${xts}))G\] $RED$ts"
    else
        PS_TIME="\[\033[\$((COLUMNS-${xts}))G\] $RED$ts"
    fi

    PS_FILL="${PS_LINE:0:$COLUMNS}"

    k="$(kubectl config current-context | cut -d'/' -f2)"

    if [[ "${k,,}" == *"dev"* || "${k,,}" == *"prod"* ]];then
        k="[$k]"
    else
        k=""
    fi
    PS1="\${PS_FILL}\[\033[0G\]${PS_INFO}\$(__gp_status) -${k}${PS_TIME}\n${RESET}\$ "
}
PROMPT_COMMAND=__prompt_command    # Function to generate PS1 after CMDs
