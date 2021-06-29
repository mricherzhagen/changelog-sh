#!/bin/bash

function _changelogsh_execute_conf_file {
  local VALIDOPTIONS="
    CHANGELOGSH_FILENAME
    CHANGELOGSH_FOLDER
    CHANGELOGSH_HEADER
    CHANGELOGSH_INCLUDE_TIMESTAMP
    CHANGELOGSH_RELEASE_STRATEGY
    CHANGELOGSH_RELEASE_COMMIT
    CHANGELOGSH_RELEASE_COMMIT_MESSAGE
    CHANGELOGSH_RELEASE_TAG
    CHANGELOGSH_RELEASE_TAG_NAME
    CHANGELOGSH_GIT_STAGE_RELEASE
    CHANGELOGSH_GIT_STAGE_CHANGE
    CHANGELOGSH_ALLOWED_CHANGETYPES
    CHANGELOGSH_FORCE_SEMVER
    CHANGELOGSH_CHECK_VERSION_GT
    CHANGELOGSH_FORCE_VERSION_GT
    CHANGELOGSH_CHECK_BUMP_INCREMENTAL
    CHANGELOGSH_EDITOR
    CHANGELOGSH_MKTEMP_OPTIONS
    CHANGELOGSH_DIFF_OPTIONS
  "
  eval "$(sh $CHANGE/ext/shdotenv -o -e $1 -g "`echo $VALIDOPTIONS | sed -E 's/\s+/|/g'`")"
}

#Always read default config from $CHANGE
_changelogsh_execute_conf_file $CHANGE/.changelog-sh-conf.sh
if TOPLEVEL_GIT="`git rev-parse --show-toplevel  2>/dev/null`" ; then
  CHANGELOGSH_INSIDE_GIT=true
  if [ -f $TOPLEVEL_GIT/.changelog-sh-conf.sh ]; then
    export CHANGELOGSH_CONF_FILE=$TOPLEVEL_GIT/.changelog-sh-conf.sh
    
    #Overwrite defaults with per project settings
    _changelogsh_execute_conf_file $CHANGELOGSH_CONF_FILE
  fi
else
  CHANGELOGSH_INSIDE_GIT=false
fi
