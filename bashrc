#!/bin/bash

BASHRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

function settings_iter() {
    local dir=$1
    local func=$2
    shift 2
    for settings in "$BASHRC_DIR"/configs/*; do
        [ -d "$settings"/"$dir" ] && $func "$settings"/"$dir" $@
    done
}

function process_settingsdir() {
    local dir=$1
    local func=$2
    local file
    for file in "$dir"/*; do
        if [ -f "$file" ]; then
            echo $func "$file"
            { time $func "$file"; } 2>&1
        else
            echo "WARN: $file not a valid $func definition file" >&2
        fi
    done
}

function add_to_path() {
    local dir=$1
    export PATH="$PATH:$dir"
}

function load_alias() {
    alias $(basename $1)="$(cat $1)"
}

{
  settings_iter aliases process_settingsdir load_alias

  settings_iter functions process_settingsdir source

  source "$BASHRC_DIR/envdefs" || return $?

  settings_iter completions process_settingsdir source

  settings_iter bin add_to_path
} > "$BASHRC_DIR"/timing.log


unset settings_iter
unset process_settingsdir
unset load_alias
unset BASHRC_DIR


# Options
shopt -s checkwinsize
shopt -s histappend   # Append to history rather than overwrite

# special case
alias ..='cd ..'
