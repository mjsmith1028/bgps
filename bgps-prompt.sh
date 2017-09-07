#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/bgps-config.sh"

_bgps_git_status() {
  local color_enabled="$(_get_config_value 'GIT_COLOR_ENABLED')"
  local color_clean="$(_get_config_value 'GIT_COLOR_CLEAN')"
  local color_untracked="$(_get_config_value 'GIT_COLOR_UNTRACKED')"
  local color_dirty="$(_get_config_value 'GIT_COLOR_DIRTY')"
  local color_default="$(_get_config_value 'GIT_COLOR_DEFAULT')"
  local color_conflict="$(_get_config_value 'GIT_COLOR_CONFLICT')"
  local pending_changes

  pending_changes="$(git status --porcelain 2>/dev/null)"
  if (( $? )) ; then
    # not in a valid git repo
    return 1
  fi
  
  pending_changes="$(echo $pending_changes | wc -w)"
  
  # get git branch info
  local git_symbol=""
  local git_color="$color_default"
  local commit_counts=($(git rev-list --left-right --count ...@{u} 2>/dev/null))
  if (( $? )) ; then
    git_color="$color_untracked"
  else
    if (( ! $pending_changes )) ; then
      git_color="$color_clean"
    fi
  
    if (( ${commit_counts[0]} )) ; then
      git_color="$color_conflict"
      git_symbol="↑[${commit_counts[0]}]"
    fi
  
    if (( ${commit_counts[1]} )) ; then
      git_color="$color_conflict"
      git_symbol="↓[${commit_counts[1]}]"
    fi
  
    if (( ${commit_counts[0]} && ${commit_counts[1]} )) ; then
      git_symbol="↕ ↑[${commit_counts[0]}] ↓[${commit_counts[1]}]"
    fi
  fi
  
  if (( $pending_changes )) ; then
    git_color="$color_dirty"
    git_symbol="*$git_symbol"
  fi
  
  if [[ $color_enabled == "true" ]] ; then
    echo -n "$git_color"
  fi
  echo "%s $git_symbol"
  # echo " %s $git_symbol" # TODO add git symbol
}

_bgps_prompt() {
  # prompt flags
  local git_prompt="false"
  
  # make sure git prompt is sourced for __git_ps1 function
  if [[ -e /etc/bash_completion.d/git-prompt ]]; then
    .  /etc/bash_completion.d/git-prompt
  fi
  # only set git_prompt flag if __git_ps1 function is defined
  if [ -n "$(type -t __git_ps1)" ] && [ "$(type -t __git_ps1)" == function ]; then 
    git_prompt="true"
  fi
  
  local pre_status="$(_get_config_value 'PRE_STATUS')"
  local post_status="$(_get_config_value 'POST_STATUS')"
  
  if [ "$git_prompt" == "true" ] ; then
    __git_ps1 "$pre_status" "$post_status" "$(_bgps_git_status)"
  else
      PS1="$pre_status $post_status"
  fi
}

_bgps_prompt_unset() {
  unset -f _bgps_git_status
  unset -f _bgps_prompt
  unset -f _bgps_prompt_unset
}

unset script_dir
