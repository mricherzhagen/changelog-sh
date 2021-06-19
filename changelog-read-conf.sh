#!/bin/bash

function _execute_conf_file {
  source $1
  export CHANGELOG_HEADER
}

#Always read default config from $CHANGE
_execute_conf_file $CHANGE/.changelog-sh-conf.sh
if TOPLEVEL_GIT="`git rev-parse --show-toplevel >/dev/null 2>&1`" ; then
  if [ -f $TOPLEVEL_GIT/.changelog-sh-conf ]; then
    export CHANGELOG_CONF_FILE=$TOPLEVEL_GIT/.changelog-sh-conf.sh
    
    #Overwrite defaults with per project settings
    _execute_conf_file $CHANGELOG_CONF_FILE
  fi
fi