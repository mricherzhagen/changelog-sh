#/usr/bin/env bash

_change_completions_match_case_suggestion_helper() {
  INPUT=$1
  SUGGESTIONS="$2"
  
  if echo "$INPUT" | grep -Eq '^[A-Za-z]{1,3}.*'; then
    # match the case of our suggestions with the current input, but only for the first 3 characters.
    # Build a string that contains a U for an uppercase character and an L for a lowercase character and has length 1-3 matching the input
    CASE_TRANSFORM_SHAPE=$(echo "$INPUT" | sed -E 's/(.{0,3}).*/\1/;s/[[:upper:]]/U/g;s/[[:lower:]]/L/g;')
    # Build string that looks like ([A-Z-z])([A-Z-z]) for input ab"
    CASE_TRANSFORM_REGEX=$(echo "$CASE_TRANSFORM_SHAPE" | sed -E 's/[LU]/([A-Za-z])/g')
    # Build string that looks like \L\1\U\2\L\3 for input aAa.
    CASE_TRANSFORM_REGEX_REPL=$(echo "$CASE_TRANSFORM_SHAPE" | sed -E 's/^([LU])(.*)/\\\1\\1\2/;s/(\\[LU]\\1)([LU])(.*)/\1\\\2\\2\3/;s/(\\[LU]\\1\\[LU]\\2)([LU])$/\1\\\2\\3/')
    SUGGESTIONS=$(echo "$SUGGESTIONS" | sed -E "s/\b$CASE_TRANSFORM_REGEX/$CASE_TRANSFORM_REGEX_REPL/g")
    echo "$SUGGESTIONS"
  else
    echo "$SUGGESTIONS"
  fi
}
_change_completions() {
  if [ ! -n "$CHANGE" ]; then
    CHANGE=~/.change
  fi
  if [ "$COMP_CWORD" = "1"  ]; then
    CHANGELOGSH_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOGSH_ALLOWED_CHANGETYPES | tr '[:upper:]' '[:lower:]'; )
    commands="init new preview full-preview release"
    TYPE_SUGGESTIONS="`_change_completions_match_case_suggestion_helper "${COMP_WORDS[1]}" "$CHANGELOGSH_ALLOWED_CHANGETYPES"`"
    COMPREPLY=($(compgen -W "$commands $TYPE_SUGGESTIONS" -- "${COMP_WORDS[1]}"))
  elif [ "$COMP_CWORD" = "2" ]; then
    case "${COMP_WORDS[1]}" in
      "new")
        CHANGELOGSH_ALLOWED_CHANGETYPES=$( source $CHANGE/changelog-read-conf.sh; echo $CHANGELOGSH_ALLOWED_CHANGETYPES | tr '[:upper:]' '[:lower:]'; )
        TYPE_SUGGESTIONS="`_change_completions_match_case_suggestion_helper "${COMP_WORDS[2]}" "$CHANGELOGSH_ALLOWED_CHANGETYPES"`"
        COMPREPLY=($(compgen -W "$TYPE_SUGGESTIONS" -- "${COMP_WORDS[2]}"))
      ;;
      release|preview|full-preview)
        source $CHANGE/changelog-helpers.sh
        source $CHANGE/changelog-read-conf.sh
        latestVersion="`_changelogsh_get_latest_version`"
        if [ ! -z "$latestVersion" ]; then
          local MAJOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "major"`"
          local MINOR_BUMP="`_changelogsh_get_next_version "$latestVersion" "minor"`"
          local PATCH_BUMP="`_changelogsh_get_next_version "$latestVersion" "patch"`"
          COMPREPLY=($(compgen -W "bump-major $MAJOR_BUMP bump-minor $MINOR_BUMP bump-patch $PATCH_BUMP" -- "${COMP_WORDS[2]}"))
        fi
      ;;
    esac
  elif [ "$COMP_CWORD" = "3" ]; then
    if [ "${COMP_WORDS[1]}" = "release" ]; then
      COMPREPLY=($(compgen -W "stage commit tag push_commit push" -- "${COMP_WORDS[3]}"))
    fi
  fi

}

complete -o nosort -F _change_completions change