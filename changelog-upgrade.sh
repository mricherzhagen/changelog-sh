#!/bin/bash

function _changelogsh_upgrade {
  if [ ! -n "$CHANGE" ]; then
    CHANGE=~/.change
  fi

  cd $CHANGE
  # Code from https://stackoverflow.com/a/22857288/2256700 and https://stackoverflow.com/a/3867811/2256700
  # Get new tags from remote
  git fetch --tags

  # Get latest tag name
  latestTag=$(git -c 'versionsort.suffix=-' tag --sort='-version:refname' -l 'v[0-9]*' | head -n 1)
  
  git diff $CHANGELOGSH_DIFF_OPTIONS $latestTag CHANGELOG.md

  # Checkout latest tag
  # Code from https://stackoverflow.com/a/45652159/2256700
  git -c advice.detachedHead=false checkout $latestTag
}
