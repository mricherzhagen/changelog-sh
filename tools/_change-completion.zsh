#compdef change changelog.sh

_change_completion() {
  if [ $CURRENT -gt 3 ]; then
    return
  fi
  if [ ! -n "$CHANGE" ]; then
    CHANGE=~/.change
  fi
  CHANGELOG_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOG_ALLOWED_CHANGETYPES )
  # Load custom completion commands
  if [ "${words[2]}" = 'new' ]; then
    _values 'changetype' `echo $CHANGELOG_ALLOWED_CHANGETYPES`
  else
    local -a subcmds
    subcmds=(\
      'init:Initialize changelog in current directory'\
      'new:Register new change in the changelog'\
      'preview:Preview the unreleased changes in Markdown format'\
      'full-preview:Preview the full changelog including unreleased changes in Markdown format'\
      'release:Release the changes for the current version'\
    )
    subcmds+=(`echo $CHANGELOG_ALLOWED_CHANGETYPES`)
    _describe 'command' subcmds
  fi
  return
}

compdef _change_completion change changelog.sh