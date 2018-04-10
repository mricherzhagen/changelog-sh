#!/bin/bash

source ~/.change/changelog-helpers.sh

function preview {
  version="Unreleased"
  if [ "$#" -gt 0 ]; then
    version=$1
  fi

  if [ ! -d "changelog/$version" ]; then
    printf "$version not found.\n"
    return
  fi

  echo "# What's new?"
  echo ""
  echo "## [$version]"

  for dir in changelog/$version/*; do
    if [ "$(ls -A $dir)" ]; then
      current=$(echo $dir | grep -o '[^/]*$')
      echo "###" $(title $current)
      for file in $dir/*; do
        echo "-" $(cat $file)
      done
      echo ""
    fi
  done
}
