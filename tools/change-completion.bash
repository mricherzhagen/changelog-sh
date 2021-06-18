#/usr/bin/env bash
_change_completions()
{
  if [ ! -n "$CHANGE" ]; then
    CHANGE=~/.change
  fi
  if [ "$COMP_CWORD" = "1"  ]; then
    CHANGELOG_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOG_ALLOWED_CHANGETYPES | tr '[:upper:]' '[:lower:]'; )
    commands="init new preview full-preview release"
    COMPREPLY=($(compgen -W "$commands $CHANGELOG_ALLOWED_CHANGETYPES" -- "${COMP_WORDS[1]}"))
  elif [ "$COMP_CWORD" = "2" -a "${COMP_WORDS[1]}" = "new" ]; then
    CHANGELOG_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOG_ALLOWED_CHANGETYPES | tr '[:upper:]' '[:lower:]'; )
    COMPREPLY=($(compgen -W "$CHANGELOG_ALLOWED_CHANGETYPES" -- "${COMP_WORDS[2]}"))
  fi

}

complete -o nosort -F _change_completions change