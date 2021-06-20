CHANGELOGSH_FILENAME='CHANGELOG.md'
CHANGELOGSH_FOLDER='changelog'
CHANGELOGSH_HEADER="# What's new?
"
CHANGELOGSH_INCLUDE_TIMESTAMP=true

# CHANGELOGSH_RELEASE_STRATEGY controls what happens with the unreleased changefiles when an release is created.
# Can be either 'move' or 'delete'.
CHANGELOGSH_RELEASE_STRATEGY='delete'

# Make the release command create a commit with the changelog changes. Requires CHANGELOGSH_GIT_STAGE_RELEASE to be enabled as well.
CHANGELOGSH_RELEASE_COMMIT=true
CHANGELOGSH_RELEASE_COMMIT_MESSAGE="Version #VERSION#"

# Make the release command also create a tag on the newly created commit. Requires CHANGELOGSH_RELEASE_COMMIT to be enabled as well.
CHANGELOGSH_RELEASE_TAG=true
CHANGELOGSH_RELEASE_TAG_NAME='v#VERSION#'

CHANGELOGSH_GIT_STAGE_RELEASE=true
CHANGELOGSH_GIT_STAGE_CHANGE=true

# Specify all allowed change types: Make sure to not include any empty lines.
CHANGELOGSH_ALLOWED_CHANGETYPES="Added
Changed
Deprecated
Removed
Fixed
Security"

CHANGELOGSH_FORCE_SEMVER=true
# Set to true to make sure that new versions are greater than the latest version in CHANGELOG.md. Requires semantic versioning.
# Will ask to continue if version number is equal or lower to latest version
CHANGELOGSH_CHECK_VERSION_GT=true;
# Will reject version numbers that are smaller or equal to the latest version. Requires CHANGELOGSH_CHECK_VERSION_GT to be enabled as well.
CHANGELOGSH_FORCE_VERSION_GT=false;

# Check that the specified version is an increment of the latest version and no version was skipped
CHANGELOGSH_CHECK_BUMP_INCREMENTAL=true

#INTERNAL
CHANGELOGSH_MKTEMP_OPTIONS="--tmpdir changelog-sh-tmp.XXXXXXXX"
CHANGELOGSH_DIFF_OPTIONS="--color=always -u"