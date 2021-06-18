#!/bin/bash

function _changelogsh_release {

  if [ ! -d "changelog/unreleased/" ]; then
    printf "Nothing to release.\n"
    return
  fi

  if [ "$#" -lt 1 ]; then
    echo "Version is required"
    return
  fi

  version=$1
  expanded=$(_changelogsh_raw_to_expanded $version)
  
  if grep -Fq "## [$version]" $CHANGELOG_FILENAME; then
    >&2 echo "Error: Version $version already exists in $CHANGELOG_FILENAME";
    exit 1;
  fi
 
  NEW_CHANGELOG=`mktemp $CHANGELOG_MKTEMP_OPTIONS`
  if _changelogsh_preview $version > $NEW_CHANGELOG; then
    diff $CHANGELOG_DIFF_OPTIONS "$CHANGELOG_FILENAME" "$NEW_CHANGELOG"
    mv $NEW_CHANGELOG "$CHANGELOG_FILENAME"
    if [ $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
        git add "$CHANGELOG_FILENAME"
    fi
  else
    >&2 echo "ERROR: Release aborted."
    rm $NEW_CHANGELOG
    exit 1
  fi
  if [ "$CHANGELOG_RELEASE_STRATEGY" = 'move' ]; then
      if [ $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
        git mv 'changelog/unreleased' "changelog/$expanded"
      else
        mv 'changelog/unreleased' "changelog/$expanded"
      fi
  elif [ "$CHANGELOG_RELEASE_STRATEGY" = 'delete' ]; then
    if [ $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
      git rm -r changelog/unreleased
    else
      rm -r changelog/unreleased
    fi
  else
      >&2 echo "ERORR: \$CHANGELOG_RELEASE_STRATEGY has to be either 'move' or 'delete'. Keeping unreleased changes.";
  fi
}
