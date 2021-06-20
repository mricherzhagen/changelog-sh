#!/bin/bash

function _changelogsh_init {
  if [ ! -d "$CHANGELOGSH_FOLDER" ]; then
    mkdir "$CHANGELOGSH_FOLDER"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/added" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/added"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/changed" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/changed"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/deprecated" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/deprecated"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/fixed" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/fixed"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/removed" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/removed"
  fi

  if [ ! -d "$CHANGELOGSH_FOLDER/unreleased/security" ]; then
    mkdir "$CHANGELOGSH_FOLDER/unreleased/security"
  fi
}
