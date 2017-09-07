#!/bin/bash

# Globals
#   BGPS_CONFIG - map of config values
#   BGPS_MAX    - length of largest key in config map

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$script_dir/bgps-config.sh"
source "$script_dir/bgps-prompt.sh"

bgps_config_file="${HOME}/.bgps_config"

# TODO implement flags better than this
if [[ $1 == "--ls-config" ]] ; then
  _print_config
elif [[ $1 == "--clear-config" ]] ; then
  _delete_config
else
  _set_config $bgps_config_file
  _bgps_prompt
fi

# clean up
_bgps_config_unset
_bgps_prompt_unset
unset bgps_config_file
unset script_dir
