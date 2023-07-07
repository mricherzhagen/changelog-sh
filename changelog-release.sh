#!/bin/bash

function _changelogsh_release {

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/" ]; then
    printf "Nothing to release.\n"
    return
  fi

  if [ "$#" -lt 1 ]; then
    echo "Version is required"
    return
  fi

  local _STEP_STAGE=1
  local _STEP_COMMIT=2
  local _STEP_TAG=3
  local _STEP_PUSH_COMMIT=4
  local _STEP_PUSH_TAG=5
  local _STEP_PUSH=6

  local _stop_at=_STEP_TAG
  
  if [ "$#" -ge 2 ]; then
    case "$2" in 
      "stage")
        _stop_at=$_STEP_STAGE
        ;;
      "commit")
        _stop_at=$_STEP_COMMIT
        ;;
      "tag")
        _stop_at=$_STEP_TAG
        ;;
      "push_commit")
        _stop_at=$_STEP_PUSH_COMMIT
        ;;
      #"push_tag")
      #  _stop_at=$_STEP_PUSH_TAG
      #  ;;
      "push")
        _stop_at=$_STEP_PUSH
        ;;
      *)
        >&2 echo "Invalid step argument '$2': Use 'stage', 'commit', 'tag', 'push_commit' or 'push"
        exit 1
        ;;
    esac
  fi

  version="`_changelogsh_parse_version_arg "$1"`"
  if [ $? -ne 0 ]; then
    exit 1
  fi
  _changelogsh_force_semver "$version"
  _changelogsh_check_new_version_gt "$version"
  local version_was_problematic=$?
  
  if [ -s "$CHANGELOGSH_FILENAME" ] && grep -Fq "## [$version]" "$CHANGELOGSH_FILENAME"; then
    >&2 echo "Error: Version $version already exists in $CHANGELOGSH_FILENAME";
    exit 1;
  fi
  
  if [ "$CHANGELOGSH_INSIDE_GIT" = true ] && [ "$CHANGELOGSH_RELEASE_COMMIT" = true ]; then
    if [ ! "$CHANGELOGSH_GIT_STAGE_RELEASE" = true ]; then
      >&2 echo "ERROR: If CHANGELOGSH_RELEASE_COMMIT is true you also need to enable the CHANGELOGSH_GIT_STAGE_RELEASE option."
      exit 1;
    fi
    if [ ! "`git diff --staged`" = "" ]; then
      read -p "You already have staged changes. Are you sure you want to continue creating a release commit? [y/N] " -r
      if ! [ "$REPLY" = "y" ] || [ "$REPLY" = "yes" ]; then
          exit 1;
      fi
    fi
    if [ ! -z "$(git ls-files  --others --exclude-standard "$CHANGELOGSH_FOLDER/unreleased")" ]; then
      >&2 echo "ERROR: You have uncommited change files in $CHANGELOGSH_FOLDER/unreleased. Commit or remove them before creating a release."
      exit 1
    fi
  fi
 
  NEW_CHANGELOG=`mktemp $CHANGELOGSH_MKTEMP_OPTIONS`
  if _changelogsh_preview "$version" > "$NEW_CHANGELOG"; then
    diff $CHANGELOGSH_DIFF_OPTIONS "$CHANGELOGSH_FILENAME" "$NEW_CHANGELOG"
    mv "$NEW_CHANGELOG" "$CHANGELOGSH_FILENAME"
    if [ "$CHANGELOGSH_GIT_STAGE_RELEASE" = true ]; then
        git add "$CHANGELOGSH_FILENAME"
    fi
  else
    >&2 echo "ERROR: Release aborted."
    rm "$NEW_CHANGELOG"
    exit 1
  fi
  if [ "$CHANGELOGSH_RELEASE_STRATEGY" = 'move' ]; then
      expanded=$(_changelogsh_raw_to_expanded $version)
      if [ "$CHANGELOGSH_GIT_STAGE_RELEASE" = true ]; then
        git mv "$CHANGELOGSH_FOLDER/unreleased" "$CHANGELOGSH_FOLDER/$expanded"
      else
        mv "$CHANGELOGSH_FOLDER/unreleased" "$CHANGELOGSH_FOLDER/$expanded"
      fi
  elif [ "$CHANGELOGSH_RELEASE_STRATEGY" = 'delete' ]; then
    if [ "$CHANGELOGSH_GIT_STAGE_RELEASE" = true ]; then
      git rm -r "$CHANGELOGSH_FOLDER/unreleased"
    else
      rm -r "$CHANGELOGSH_FOLDER/unreleased"
    fi
  else
      >&2 echo "ERORR: \$CHANGELOGSH_RELEASE_STRATEGY has to be either 'move' or 'delete'. Keeping unreleased changes.";
      exit 1;
  fi
  if [ $version_was_problematic -ne 0 ]; then
    echo "Because your version number $version was lower than the latest version the changes were not committed automatically."
    echo "Maybe you need to move the created version to a different spot in the CHANGELOG.md?"
    echo "Verify the changes and then continue with:"
    echo ""
    _stop_at=$_STEP_STAGE
  else
    if [ $_stop_at -eq $_STEP_STAGE ]; then
      echo "Staged changes."
      echo "Please review changes before continuing with:"
      echo ""
    fi
  fi

  local _error_occured=0

  if [ "$CHANGELOGSH_INSIDE_GIT" = true ] && [ "$CHANGELOGSH_RELEASE_COMMIT" = true ] && [ "$CHANGELOGSH_GIT_STAGE_RELEASE" = true ]; then
    if [ $_stop_at -ge $_STEP_COMMIT ]; then
      if git commit -m "${CHANGELOGSH_RELEASE_COMMIT_MESSAGE//#VERSION#/$version}"; then
        echo "Created version commit"
      else
        >&2 echo "ERROR: An error occured creating the release commit."
        echo "Check your release manually! Then continue with:"
        echo ""
        _stop_at=0
        _error_occured=1
      fi
    fi
    if [ $_stop_at -lt $_STEP_COMMIT ]; then
      echo "    git commit -m '${CHANGELOGSH_RELEASE_COMMIT_MESSAGE//#VERSION#/$version}'"
    elif [ $_stop_at -eq $_STEP_COMMIT ]; then
      echo "Please review changes before continuing with:"
      echo ""
    fi

    if [ "$CHANGELOGSH_RELEASE_TAG" = true ]; then
      TAGNAME="${CHANGELOGSH_RELEASE_TAG_NAME//#VERSION#/$version}"
      if [ $_stop_at -ge $_STEP_TAG ]; then
        if git tag "$TAGNAME"; then
          echo "Created tag $TAGNAME"
        else
          >&2 echo "ERROR: An error occured creating the tag $TAGNAME."
          echo "Check your release manually! Then continue with:"
          echo ""
          _stop_at=0
          _error_occured=2
        fi
      fi
      if [ $_stop_at -lt $_STEP_TAG ]; then
        echo "    git tag '$TAGNAME'"
      fi
    fi
    if [ $_stop_at -eq $_STEP_TAG ]; then
      echo "Please review changes before continuing with:"
      echo ""
    fi

    # Code for getting remote name from https://stackoverflow.com/a/9753364/2256700
    REMOTE_NAME=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null | sed 's@/.*$@@')
    REMOTE_NAME="${REMOTE_NAME:-<remote>}"
    if [ $_stop_at -ge $_STEP_PUSH_COMMIT ]; then
      if [ "$REMOTE_NAME" = '<remote>' ]; then
        >&2 echo "ERROR: Could not determine remote for pushing."
        echo "Continue with:"
        echo ""
        _stop_at=0
      fi
    fi
    if [ $_stop_at -ge $_STEP_PUSH_COMMIT ]; then
      if git push "$REMOTE_NAME"; then
        echo "Pushed Version commit"
      else
        >&2 echo "ERROR: Could not push to remote."
        echo "Fix error and continue with:"
        echo ""
        _stop_at=0
      fi
    fi
    if [ $_stop_at -le $_STEP_PUSH_COMMIT ]; then
      echo "    git push $REMOTE_NAME"
    fi

    if [ "$CHANGELOGSH_RELEASE_TAG" = true ]; then
      if [ $_stop_at -ge $_STEP_PUSH_TAG ]; then
        if git push "$REMOTE_NAME" "$TAGNAME"; then
          echo "Pushed Version tag"
        else
          >&2 echo "ERROR: Could not push tag to remote."
          echo "Fix error and continue with:"
          echo ""
          _stop_at=0
        fi
      fi
      if [ $_stop_at -le $_STEP_PUSH_COMMIT ]; then
        echo "    git push $REMOTE_NAME $TAGNAME"
      fi
    fi
    if [ $_stop_at -ge $_STEP_PUSH_COMMIT ]; then
      echo "Thanks for putting trust into this software. You really shouldn't, though."
      echo "Review your changes."
    fi
    if [ $_error_occured -ne 0 ]; then
      exit $_error_occured
    fi
  fi
}
