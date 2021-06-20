#!/bin/bash

function _changelogsh_execute_conf_file {
  source $1
  export CHANGELOGSH_HEADER
}

#Always read default config from $CHANGE
_changelogsh_execute_conf_file $CHANGE/.changelog-sh-conf.sh
if TOPLEVEL_GIT="`git rev-parse --show-toplevel >/dev/null 2>&1`" ; then
  CHANGELOGSH_INSIDE_GIT=true
  if [ -f $TOPLEVEL_GIT/.changelog-sh-conf ]; then
    export CHANGELOGSH_CONF_FILE=$TOPLEVEL_GIT/.changelog-sh-conf.sh
    
    #Overwrite defaults with per project settings
    _changelogsh_execute_conf_file $CHANGELOGSH_CONF_FILE
  fi
else
  CHANGELOGSH_INSIDE_GIT=false
fi