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
  
  if [ $CHANGELOG_INSIDE_GIT = true -a $CHANGELOG_RELEASE_COMMIT = true ]; then
    if [ ! $CHANGELOG_GIT_STAGE_RELEASE = true]; then
      >&2 echo "ERROR: If CHANGELOG_RELEASE_COMMIT is true you also need to enable the CHANGELOG_GIT_STAGE_RELEASE option."
      exit 1;
    fi
    if [ ! "`git diff --staged`" = "" ]; then
      read -p "You already have staged changes. Are you sure you want to continue creating a release commit? [y/N] " -r
      if ! [ "$REPLY" = "y" -o "$REPLY" = "yes" ]; then
          exit 1;
      fi
    fi
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
      exit 1;
  fi
  if [ $CHANGELOG_INSIDE_GIT = true -a $CHANGELOG_RELEASE_COMMIT = true -a $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
    if git commit -m "`echo "$CHANGELOG_RELEASE_COMMIT_MESSAGE" | sed "s/#VERSION#/$version/"`"; then
      echo "Created version commit"
    else
      >&2 echo "ERROR: An error occured creating the release commit. Check your release manually!"
      exit 1
    fi
    if [ $CHANGELOG_RELEASE_TAG = true ]; then
      TAGNAME="v$version"
      if git tag "$TAGNAME"; then
        echo "Created tag $TAGNAME"
      else
        >&2 echo "ERROR: An error occured creating the tag $TAGNAME. Check your release manually!"
        exit 1;
      fi
    fi
    echo "Please review changes before pushing"
    if [ $CHANGELOG_RELEASE_TAG = true ]; then
      # Code for getting remote name from https://stackoverflow.com/a/9753364/2256700
      REMOTE_NAME=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | sed 's@/.*$@@')
      echo "Remember to also push the release tag with"
      echo ""
      echo "    git push $REMOTE_NAME $TAGNAME"
    fi
  fi
}
