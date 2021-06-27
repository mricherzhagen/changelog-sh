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
      local CHANGEMESSAGE="$(echo ${@:2})"
  else
    local TEMPFILE=$(mktemp $CHANGELOGSH_MKTEMP_OPTIONS)
    echo '# Write your changelog entry for change type "'"$type"'" as a single line. Lines beginning with # will be ignored.' > $TEMPFILE
    ${CHANGELOGSH_EDITOR:-$EDITOR} $TEMPFILE
    local CHANGEMESSAGE="$(grep -v -E '^\s*#.+$' $TEMPFILE)"
    rm $TEMPFILE
  fi
  if [ ! -z "$CHANGEMESSAGE" ]; then
    echo $CHANGEMESSAGE > "$CHANGELOGSH_FOLDER/unreleased/$type/$timestamp"
    if [ $CHANGELOGSH_GIT_STAGE_CHANGE = true ]; then
      git add "$CHANGELOGSH_FOLDER/unreleased/$type/$timestamp"
    fi
  else
    echo >&2 "No change message was provided. Aborting."
  fi

}
