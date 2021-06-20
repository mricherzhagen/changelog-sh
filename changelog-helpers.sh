#!/bin/bash

function _changelogsh_title {
  input=$1
  echo $(echo ${input:0:1} | tr  '[a-z]' '[A-Z]')${input:1}
}

function _changelogsh_raw_to_expanded {
  input="$1"
  split=("${input//./ }")
  echo $split | xargs printf '%03d'
}

function _changelogsh_expanded_to_raw {
  input=$1
  split=($(echo $input | fold -w3))

  echo $split | sed 's/^0*//g; s/ 0*/./g'
}

function _changelogsh_is_semver {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-.+)?$'
    return $?
}

function _changelogsh_force_semver {
  if [ $CHANGELOG_FORCE_SEMVER = true ] && ! _changelogsh_is_semver $1; then
    >&2 echo "ERROR: $1 is not a semantic version number and CHANGELOG_FORCE_SEMVER is enabled."
    exit 1;
  fi
}