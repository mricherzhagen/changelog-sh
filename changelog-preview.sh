#!/bin/bash

function _changelogsh_preview {
  raw_version="Unreleased"
  if [ "$#" -gt 0 ]; then
    raw_version=$1
  fi

  echo "$CHANGELOG_HEADER"
  echo "## [$raw_version]"

  for dir in changelog/unreleased/*; do
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