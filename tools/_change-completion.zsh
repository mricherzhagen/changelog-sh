#compdef change changelog.sh

_change_completion() {
  local getVersionBumps='
  source $CHANGE/changelog-helpers.sh
  source $CHANGE/changelog-read-conf.sh
  latestVersion="`_changelogsh_get_latest_version`"
  echo LATEST_VERSION="$latestVersion"
  if [ ! -z "$latestVersion" ]; then
    echo MAJOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "major"`"
    echo MINOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "minor"`"
    echo PATCH_BUMP="`_changelogsh_get_next_version "$latestVersion" "patch"`"
  else
    exit 1
  fi
'
  if [ $CURRENT -gt 3 ]; then
    return
  fi
  if [ ! -n "$CHANGE" ]; then
    CHANGE=~/.change
  fi
  CHANGELOGSH_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOGSH_ALLOWED_CHANGETYPES )
  # Load custom completion commands
  case "${words[2]}" in
    'new')
      _values 'changetype' `echo $CHANGELOGSH_ALLOWED_CHANGETYPES`
    ;;
    release|preview|full-preview)
      local versionbumps="$(CHANGE=$CHANGE bash -c "$getVersionBumps"; exit $? )"
      eval "$versionbumps"
      if [ ! -z "$LATEST_VERSION" ]; then
        _message -r "Latest version: $LATEST_VERSION"
        local -a versionbumps
        versionbumps=(\
          "bump-patch:Bump patch version to $PATCH_BUMP"\
          "bump-minor:Bump minor version to $MINOR_BUMP"\
          "bump-major:Bump major version to $MAJOR_BUMP"\
          "$PATCH_BUMP:Bump patch version"\
          "$MINOR_BUMP:Bump minor version"\
          "$MAJOR_BUMP:Bump major version"\
        )
        _describe 'version' versionbumps
      else
        _message -r "Enter Version number. Could't determine latest version."
      fi
    ;;
    *)
    local -a subcmds
    subcmds=(\
      'init:Initialize changelog in current directory'\
      'new:Register new change in the changelog'\
      'preview:Preview the unreleased changes in Markdown format'\
      'full-preview:Preview the full changelog including unreleased changes in Markdown format'\
      'release:Release the changes for the current version'\
    )
    subcmds+=(`echo $CHANGELOGSH_ALLOWED_CHANGETYPES`)
    _describe 'command' subcmds
  esac
  return
}

compdef _change_completion change changelog.sh