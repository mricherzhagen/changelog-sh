#!/bin/bash

function _changelogsh_preview {
    
  if [ "$#" -gt 0 ]; then
    version="`_changelogsh_parse_version_arg $1`"
    _changelogsh_force_semver "$version"
    _changelogsh_check_new_version_gt "$version"
    
    if [ $CHANGELOGSH_CHECK_BUMP_INCREMENTAL = true ] ; then
      local latestVersion="`_changelogsh_get_latest_version`"
      local MAJOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "major"`"
      local MINOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "minor"`"
      local PATCH_BUMP="`_changelogsh_get_next_version "$latestVersion" "patch"`"
      local trimmedVersion="${version%-*}"
      if [ "$trimmedVersion" != "$MAJOR_BUMP" -a "$trimmedVersion" != "$MINOR_BUMP" -a "$trimmedVersion" != "$PATCH_BUMP" ]; then
        read -p "The specified version $version is not an increment of the latest version $latestVersion. Do you really want to skip a version? [y/N] " -r
        if ! [ "$REPLY" = "y" -o "$REPLY" = "yes" ]; then
            exit 1;
        fi
      fi
    fi
  fi

  CHANGELOGSH_TEMPFILE=""
  if [ -s "$CHANGELOGSH_FILENAME" ]; then
    HEADER_TEMPFILE=`mktemp $CHANGELOGSH_MKTEMP_OPTIONS`
    echo "$CHANGELOGSH_HEADER" > $HEADER_TEMPFILE


    HEADER_BYTES=`stat --printf="%s" $HEADER_TEMPFILE`
    CHANGELOGSH_TEMPFILE=`mktemp $CHANGELOGSH_MKTEMP_OPTIONS`
    head -c $HEADER_BYTES $CHANGELOGSH_FILENAME > $CHANGELOGSH_TEMPFILE

    if ! DIFF_OUTPUT=`diff $CHANGELOGSH_DIFF_OPTIONS $HEADER_TEMPFILE $CHANGELOGSH_TEMPFILE`; then
      rm $HEADER_TEMPFILE $CHANGELOGSH_TEMPFILE
      >&2 echo "Header in $CHANGELOGSH_FILENAME changed:"
      >&2 echo "$DIFF_OUTPUT"
      exit 1
    fi
    tail -c+`expr $HEADER_BYTES + 1` "$CHANGELOGSH_FILENAME" > $CHANGELOGSH_TEMPFILE
    rm $HEADER_TEMPFILE
  fi
  
  echo "$CHANGELOGSH_HEADER"
  _changelogsh_preview_unreleased "$version"
  
  if [ ! -z "$CHANGELOGSH_TEMPFILE" -a -s "$CHANGELOGSH_TEMPFILE" ]; then
    cat $CHANGELOGSH_TEMPFILE
    rm $CHANGELOGSH_TEMPFILE
  fi
}

function _changelogsh_preview_unreleased {
  raw_version="Unreleased"
  if [ "$#" -gt 0 ]; then
    raw_version="`_changelogsh_parse_version_arg $1`"
    _changelogsh_force_semver "$raw_version"
  fi

  if [ $CHANGELOGSH_INCLUDE_TIMESTAMP = true ]; then
    echo "## [$raw_version] - `date +%F`"
  else
    echo "## [$raw_version]"
  fi

  for dir in "$CHANGELOGSH_FOLDER/unreleased/"*; do
    if [ "$(ls -A $dir)" ]; then
      current=$(echo $dir | grep -o '[^/]*$')
      echo "###" $(_changelogsh_title $current)
      for file in $dir/*; do
        echo "-" $(cat $file)
      done
      echo ""
    fi
  done
}