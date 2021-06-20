#compdef change changelog.sh

_change_completion() {
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
      _values 'version' 'bump-major' 'bump-minor' 'bump-patch'
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