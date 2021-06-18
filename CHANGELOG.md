# What's new?

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
