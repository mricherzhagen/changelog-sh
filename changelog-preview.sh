#!/bin/bash

function _changelogsh_preview {
  CHANGELOG_TEMPFILE=""
  if [ -s "$CHANGELOG_FILENAME" ]; then
    HEADER_TEMPFILE=`mktemp $CHANGELOG_MKTEMP_OPTIONS`
    echo "$CHANGELOG_HEADER" > $HEADER_TEMPFILE


    HEADER_BYTES=`stat --printf="%s" $HEADER_TEMPFILE`
    CHANGELOG_TEMPFILE=`mktemp $CHANGELOG_MKTEMP_OPTIONS`
    head -c $HEADER_BYTES $CHANGELOG_FILENAME > $CHANGELOG_TEMPFILE

    if ! DIFF_OUTPUT=`diff $CHANGELOG_DIFF_OPTIONS $HEADER_TEMPFILE $CHANGELOG_TEMPFILE`; then
      rm $HEADER_TEMPFILE $CHANGELOG_TEMPFILE
      >&2 echo "Header in $CHANGELOG_FILENAME changed:"
      >&2 echo "$DIFF_OUTPUT"
      exit 1
    fi
    tail -c+`expr $HEADER_BYTES + 1` "$CHANGELOG_FILENAME" > $CHANGELOG_TEMPFILE
    rm $HEADER_TEMPFILE
  fi
  
  echo "$CHANGELOG_HEADER"
  _changelogsh_preview_unreleased ${@:1}
  
  if [ ! -z "$CHANGELOG_TEMPFILE" -a -s "$CHANGELOG_TEMPFILE" ]; then
    cat $CHANGELOG_TEMPFILE
    rm $CHANGELOG_TEMPFILE
  fi
}

function _changelogsh_preview_unreleased {
  raw_version="Unreleased"
  if [ "$#" -gt 0 ]; then
    raw_version=$1
  fi

  if [ $CHANGELOG_INCLUDE_TIMESTAMP = true ]; then
    echo "## [$raw_version] - `date +%F`"
  else
    echo "## [$raw_version]"
  fi

  for dir in "$CHANGELOG_FOLDER/unreleased/"*; do
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