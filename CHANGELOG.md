# What's new?

## [5.0.1] - 2024-01-12
### Fixed
- Error when executing `change release` without step argument
- Some `shellcheck` errors and warnings

## [5.0.0] - 2023-07-07
### Added
- Added `release` argument to specify the steps to execute. Valid steps are `stage`, `commit`, `tag`.
- Experimental automatic pushing of commit and tag with push_commit, push_tag and push release step.

### Changed
- Print remaining steps when error occurs during release

### Fixed
- Fix `change upgrade` not upgrading to latest tag

## [4.2.0] - 2022-10-28
### Fixed
- Always execute commands from toplevel git folder

## [4.1.4] - 2022-08-11
### Changed
- Add newlines to editor tempfile

## [4.1.3] - 2022-05-31
### Fixed
- Errors on OSX because `sed -E` does not support `\s`. Using `[[:space:]]` instead.
- Install script now recommends alias using `bash` instead of `sh`, because of errors on Ubuntu.

## [4.1.2] - 2022-03-23
### Fixed
- Awk errors with ZSH autocompletion

## [4.1.1] - 2021-06-29
### Fixed
- `.changelog-sh-conf.sh` was ignored, because `shdotenv` was missing the `-o` argument.

## [4.1.0] - 2021-06-27
### Added
- Calling `change new <type>` without a change message will spawn text editor.
- `CHANGELOGSH_EDITOR` option to overwrite the default `$EDITOR` variable to determine the editor to spawn.

### Changed
- Autocompletion now also suggest the bumped version numbers themself.
- ZSH-Autocompletion also prints the latest version number when available.
- `_changelogsh_get_latest_version` does not parse the full changelog to determine the latest version number anymore.

## [4.0.0] - 2021-06-27
### Added
- Dependency: `shdotenv` tool from https://github.com/ko1nksm/shdotenv to parse configuration file without executing it

### Removed
- Security warning in `README.md` about `.changelog-sh-conf.sh`

### Security
- The `.changelog-sh-conf.sh` configuration file is not executed with `source` anymore.

## [3.0.4] - 2021-06-27
### Added
- Check for untracked files in `.changelog/unreleased` when calling `change release`.

### Fixed
- `wget` command in `README.md` was missing `-O -` argument
- `CHANGELOGSH_FILENAME` not being used at all places where it should.
- Error messages from `grep` and `sed` if `CHANGELOG.md` file did not exist when calling `change release`
- Output of `change release` if no remote could be found. Substitute with `<remote>`.
- Now only one error message is displayed if `bump-*` fails because of missing `CHANGELOG.md`.

## [3.0.3] - 2021-06-21
### Fixed
- `.changelog-sh-conf.sh` not being read from git repositories.
- Some errors if latest version couldn't be determined from CHANGELOG.md.
- Error if `change full-preview` was called without version argument.

## [3.0.2] - 2021-06-20
### Added
- Section about `bump-*` to `README.md`.

## [3.0.1] - 2021-06-20
### Fixed
- Missing `_changelogsh_` prefix for `execute_conf_file` function

## [3.0.0] - 2021-06-20
### Changed
- Change default folder for storing changes from `changelog` to `.changelog`. Make sure to migrate your changes to the new folder.
- Change Configuration prefix from `CHANGELOG_` to `CHANGELOGSH_`. Make sure to update your configuration files.

## [2.7.0] - 2021-06-20
### Added
- Specify `bump-major`, `bump-minor` or `bump-patch` as a version argument and the respective number will be increased.
- Use `bump-major-something` as the version argument to append `-something` to the generated version.
- `CHANGELOG_CHECK_BUMP_INCREMENTAL` option to check that no version is skipped. Defaults to `true`.
- Autocomplete `bump-(major|minor|patch)` for version arguments

## [2.6.0] - 2021-06-20
### Added
- `CHANGELOG_FOLDER` option to configure where to store the changes. Defaults to the old `changelog` name, but will change in future versions.
- `CHANGELOG_FORCE_SEMVER` option to verify that versions match semantic versioning. Defaults to `true`.
- `CHANGELOG_CHECK_VERSION_GT` option to check if version is greater than the latest version from `CHANGELOG.md`. Will ask for confirmation if not. Defaults to `true`.
- `CHANGELOG_FORCE_VERSION_GT` option to abort if specified version is lower than latest version. Defaults to `false`.

## [2.5.2] - 2021-06-20
### Added
- `change upgrade` now displays the `CHANGELOG.md` differences for the upgrade.

## [2.5.1] - 2021-06-20
### Changed
- `change release` now prints both required push commands

### Fixed
- Syntax error when there were staged changes and `change release` was called

## [2.5.0] - 2021-06-20
### Changed
- `install.sh` script now installs latest version tag instead of `msater` branch
- `change upgrade` now upgrades to the latest version tag
- `install.sh` script now also prints .rc contents for adding `change` to the `$PATH`.

## [2.4.0] - 2021-06-20
### Added
- `CHANGELOG_RELEASE_COMMIT` option to automatically create a release-commit with the changelog changes.
- `CHANGELOG_RELEASE_TAG` option to also automatically tag the release commit.
- `CHANGELOG_RELEASE_COMMIT_MESSAGE` option to configure release commit message
- `CHANGELOG_RELEASE_TAG_NAME` option to set release tag name
- Warning in `README.md` about security implications of `.changelog-sh-conf.sh` file.

## [2.3.0] - 2021-06-19
### Added
- Bash-Completion script for the `change` command.
- ZSH-Completion script for the `change` command. (Known Bug: Also suggests files when `alias` for `changelog.sh` is used.)

### Changed
- Updated `README.md`

### Fixed
- Suppress error message when `change` is called outside of a `git` repository

## [2.2.1] - 2021-06-18
### Added
- Shorthand for `change new [changetype] [message]` command. Can directly call `change [changetype] [message]` without specifying `new`.

### Changed
- `change release` checks if the `CHANGELOG.md` already contains an entry for the specified version

## [2.2.0] - 2021-06-18
### Added
- `CHANGELOG_ALLOWED_CHANGETYPES` option to specify allowed changetypes

### Changed
- `change new` only allows changetypes from `CHANGELOG_ALLOWED_CHANGETYPES`.

### Fixed
- Always convert changetype to lowercase when creating changetype folder

## [2.1.0] - 2021-06-18
### Added
- `CHANGELOG_GIT_STAGE_RELEASE` option. If enabled `change release` will automatically stage changes to `CHANGELOG.md` and changefiles. Defaults to `true.`
- `CHANGELOG_GIT_STAGE_CHANGE` option. If enabled `change new` will automatically stage the new changefile. Defaults to `true`.

## [2.0.0] - 2021-06-18
### Added
- Config file `.changelog-sh-conf.sh` will be read from `$CHANGE` and git root folder if existent
- Allow to configure Changelog Header
- `full-preview` command embeds unreleased changes into existing Changelog file
- `CHANGELOG_INCLUDE_TIMESTAMP` option to include the release dates in the changelog. Defaults to `true`.
- `CHANGELOG_RELEASE_STRATEGY` option to control what happens with the changefiles on release. Can be either `move` or `delete`. Defaults to `delete`.

### Changed
- Install script installs from fork
- Install script does not call `sudo` anymore. Use alias or $PATH
- `change preview` will always preview the unreleased changes with an optional version number
- `changelog release` command updates the `CHANGELOG.md` file to include new release
- `change release` command prints unified diff to CHANGELOG.md

### Removed
- `change unrelease` command has been removed. Use `git` to revert changes in changelog.

## [1.0.0]
Initial version from https://github.com/whitecloakph/changelog-sh
