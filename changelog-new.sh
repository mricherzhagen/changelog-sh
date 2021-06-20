#!/bin/bash

function _changelogsh_new {

  timestamp=$(date +"%Y%m%d%H%M%S")
  type='fixed'

  if [ ! -d "$CHANGELOGSH_FOLDER" ]; then
    mkdir "$CHANGELOGSH_FOLDER"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased"
  fi

  if [ "$#" -ge 1 ]; then
    if [ ! -z "$CHANGELOGSH_ALLOWED_CHANGETYPES" ] && ! echo "$1" | grep -Fqi "$CHANGELOGSH_ALLOWED_CHANGETYPES"; then
        >&2 echo "ERROR: '$1' is not an allowed change type."
        >&2 echo "Allowed change types are": $CHANGELOGSH_ALLOWED_CHANGETYPES
        exit 1
    fi
    type=`echo "$1" | tr '[:upper:]' '[:lower:]'`
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/$type" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/$type"
  fi

  if [ "$#" -ge 2 ]; then
    echo ${@:2} > "$CHANGELOGSH_FOLDER/unreleased/$type/$timestamp"
    if [ $CHANGELOGSH_GIT_STAGE_CHANGE = true ]; then
        git add "$CHANGELOGSH_FOLDER/unreleased/$type/$timestamp"
    fi
  fi

}
