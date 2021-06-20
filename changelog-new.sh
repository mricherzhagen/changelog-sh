#!/bin/bash

function _changelogsh_new {

  timestamp=$(date +"%Y%m%d%H%M%S")
  type='fixed'

  if [ ! -d "$CHANGELOG_FOLDER" ]; then
    mkdir "$CHANGELOG_FOLDER"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased"
  fi

  if [ "$#" -ge 1 ]; then
    if [ ! -z "$CHANGELOG_ALLOWED_CHANGETYPES" ] && ! echo "$1" | grep -Fqi "$CHANGELOG_ALLOWED_CHANGETYPES"; then
        >&2 echo "ERROR: '$1' is not an allowed change type."
        >&2 echo "Allowed change types are": $CHANGELOG_ALLOWED_CHANGETYPES
        exit 1
    fi
    type=`echo "$1" | tr '[:upper:]' '[:lower:]'`
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/$type" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/$type"
  fi

  if [ "$#" -ge 2 ]; then
    echo ${@:2} > "$CHANGELOG_FOLDER/unreleased/$type/$timestamp"
    if [ $CHANGELOG_GIT_STAGE_CHANGE = true ]; then
        git add "$CHANGELOG_FOLDER/unreleased/$type/$timestamp"
    fi
  fi

}
