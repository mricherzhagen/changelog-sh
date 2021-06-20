# Changelog.sh

`changelog.sh` is a tool to keep a changelog without conflicts. It supports rendering your changelog into a standard [keepachangelog](https://keepachangelog.com) format.

This is a **fork** of [whitecloakph/changelog-sh](https://github.com/whitecloakph/changelog-sh) with *extensive* changes to the functionality. See the [CHANGELOG.md](CHANGELOG.md) for a list of changes.

**WARNING:** as of now all `change` commands and also the `change` autocompletion functions will `source`/execute any `.changelog-sh-conf.sh` file in git repositories that `change` is used in. Beware of the security implications and only run in trusted repositories.

## Motivation

Maintaining a `CHANGELOG.md` is annoying because it's prone to merge conflict. Multiple developer adding line to a single file will confuse git as to which change should go first.

## Solution

The solution is to create a file for each changelog entry that can be commited to git. This strategy avoid merge conflicts when multiple developers add a changelog entry.

## How it works

New changes are recorded using the `change new [changetype] [changelog entry]` command. Each change is written into a `changelog/unreleased` directory as a separate file.

Having a `changelog` directory looking like this:

```
changelog/
  unreleased/
    added/
      19860806201409
    changed/
      19860806144612
    fixed/
      19860806092409
      19860806202703
```

would yield a new entry in the `CHANGELOG.md` that would like this:

```markdown
## [Unreleased] - 1987-07-27
### Added
- Never gonna give you up

### Changed
- Never gonna let you down

### Fixed
- [124] Never gonna run around and desert you
- [123] Never gonna make you cry
```

This can be displayed using the `change preview` command.

When a new release is created this entry is inserted into the `CHANGELOG.md` file and the files in `changelog/unreleased` are automatically deleted or moved.

The `change full-preview 2.0.0` command can show you what the `CHANGELOG.md` file would look like if the unreleased changes were to be released as version `2.0.0`:
```markdown
# What's new?

## [2.0.0] - 1987-07-27
### Added
- Never gonna give you up

### Changed
- Never gonna let you down

### Fixed
- [124] Never gonna run around and desert you
- [123] Never gonna make you cry

## [1.1.0] - 1987-05-03
### Added
- Never gonna say good bye

## [1.0.0] - 1986-12-07
### Added
- Never gonna tell a lie and hurt you
```

The `change release 2.0.0` command can then be used to write the new version into the `CHANGELOG.md` file and remove the files in `changelog/unreleased`, so they are not released again.

## Getting Started

### Basic Installation

Changelog.sh is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`. (Take a look at the [`install.sh`](https://raw.githubusercontent.com/mricherzhagen/changelog-sh/master/tools/install.sh) first!)

#### via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/mricherzhagen/changelog-sh/master/tools/install.sh)"
```

#### via wget

```shell
sh -c "$(wget https://raw.githubusercontent.com/mricherzhagen/changelog-sh/master/tools/install.sh)"
```

### Shell autocompletion

There is experimental autocompletion support for `bash` and `zsh` available. 
#### for `bash`
Add to your `.bashrc`:
```shell
source ~/.change/tools/change-completion.bash
```

#### for `zsh`
Add to your `.zshrc`:
```shell
source ~/.change/tools/_change-completion.zsh
```

### Basic Usage

#### Initialize

```shell
change init
```

#### Add new change

```shell
change new {type_of_change} {message}
```

#### Preview changelog in Markdown format

```shell
change preview
```

#### Release changes

```shell
change release {version}
```

#### Version bumping

The `preview`, `full-review` and `release` commands can take the arguments `bump-major`, `bump-minor` and `bump-patch` to automatically calculate the next version number.

You can also use `bump-major-something` to append `-something` to the generated version.