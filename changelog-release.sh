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
 
  NEW_CHANGELOG=`mktemp $CHANGELOG_MKTEMP_OPTIONS`
  if _changelogsh_preview $version > $NEW_CHANGELOG; then
    diff $CHANGELOG_DIFF_OPTIONS "$CHANGELOG_FILENAME" "$NEW_CHANGELOG"
    mv $NEW_CHANGELOG "$CHANGELOG_FILENAME"
  else
    >&2 echo "ERROR: Release aborted."
    rm $NEW_CHANGELOG
    exit 1
  fi
  if [ "$CHANGELOG_RELEASE_STRATEGY" = 'move' ]; then
    mv 'changelog/unreleased' "changelog/$expanded"
  elif [ "$CHANGELOG_RELEASE_STRATEGY" = 'delete' ]; then
    rm -r changelog/unreleased
  else
      >&2 echo "ERORR: \$CHANGELOG_RELEASE_STRATEGY has to be either 'move' or 'delete'. Keeping unreleased changes.";
  fi
}
