#!/bin/bash

function _changelogsh_release {

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/" ]; then
    printf "Nothing to release.\n"
    return
  fi

  if [ "$#" -lt 1 ]; then
    echo "Version is required"
    return
  fi

  version="`_changelogsh_parse_version_arg $1`"
  _changelogsh_force_semver $version
  _changelogsh_check_new_version_gt $version
  local version_was_problematic=$?
  
  if grep -Fq "## [$version]" $CHANGELOG_FILENAME; then
    >&2 echo "Error: Version $version already exists in $CHANGELOG_FILENAME";
    exit 1;
  fi
  
  if [ $CHANGELOG_INSIDE_GIT = true -a $CHANGELOG_RELEASE_COMMIT = true ]; then
    if [ ! $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
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
      expanded=$(_changelogsh_raw_to_expanded $version)
      if [ $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
        git mv "$CHANGELOG_FOLDER/unreleased" "$CHANGELOG_FOLDER/$expanded"
      else
        mv "$CHANGELOG_FOLDER/unreleased" "$CHANGELOG_FOLDER/$expanded"
      fi
  elif [ "$CHANGELOG_RELEASE_STRATEGY" = 'delete' ]; then
    if [ $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
      git rm -r "$CHANGELOG_FOLDER/unreleased"
    else
      rm -r "$CHANGELOG_FOLDER/unreleased"
    fi
  else
      >&2 echo "ERORR: \$CHANGELOG_RELEASE_STRATEGY has to be either 'move' or 'delete'. Keeping unreleased changes.";
      exit 1;
  fi
  if [ $CHANGELOG_INSIDE_GIT = true -a $CHANGELOG_RELEASE_COMMIT = true -a $CHANGELOG_GIT_STAGE_RELEASE = true ]; then
    if [ $version_was_problematic -eq 0 ]; then
      if git commit -m "`echo "$CHANGELOG_RELEASE_COMMIT_MESSAGE" | sed "s/#VERSION#/$version/"`"; then
        echo "Created version commit"
      else
        >&2 echo "ERROR: An error occured creating the release commit. Check your release manually!"
        exit 1
      fi
      if [ $CHANGELOG_RELEASE_TAG = true ]; then
        TAGNAME="`echo "$CHANGELOG_RELEASE_TAG_NAME" | sed "s/#VERSION#/$version/"`"
        if git tag "$TAGNAME"; then
          echo "Created tag $TAGNAME"
        else
          >&2 echo "ERROR: An error occured creating the tag $TAGNAME. Check your release manually!"
          exit 1;
        fi
      fi
      echo "Please review changes before pushing with:"
    else
      echo "Because your version number $version was lower than the latest version the changes were not committed automatically."
      echo "Maybe you need to move the created version to a different spot in the CHANGELOG.md?"
      echo "Verify the changes and then confirm them with:"
      echo ""
      echo "    git commit -m '`echo "$CHANGELOG_RELEASE_COMMIT_MESSAGE" | sed "s/#VERSION#/$version/"`"
      if [ $CHANGELOG_RELEASE_TAG = true ]; then
        TAGNAME="`echo "$CHANGELOG_RELEASE_TAG_NAME" | sed "s/#VERSION#/$version/"`"
        echo "    git tag '$TAGNAME'"
      fi
      echo ""
      echo "then continue with:"
    fi

    # Code for getting remote name from https://stackoverflow.com/a/9753364/2256700
    REMOTE_NAME=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | sed 's@/.*$@@')
    
    echo ""
    echo "    git push $REMOTE_NAME"
    if [ $CHANGELOG_RELEASE_TAG = true ]; then
      echo "    git push $REMOTE_NAME $TAGNAME"
    fi
  fi
}
