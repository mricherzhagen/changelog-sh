#!/bin/bash

function _changelogsh_init {
  if [ ! -d "$CHANGELOG_FOLDER" ]; then
    mkdir "$CHANGELOG_FOLDER"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/added" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/added"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/changed" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/changed"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/deprecated" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/deprecated"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/fixed" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/fixed"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/removed" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/removed"
  fi

  if [ ! -d "$CHANGELOG_FOLDER/unreleased/security" ]; then
    mkdir "$CHANGELOG_FOLDER/unreleased/security"
  fi
}
