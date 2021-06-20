CHANGELOG_FILENAME='CHANGELOG.md'
CHANGELOG_HEADER="# What's new?
"
CHANGELOG_INCLUDE_TIMESTAMP=true

# CHANGELOG_RELEASE_STRATEGY controls what happens with the unreleased changefiles when an release is created.
# Can be either 'move' or 'delete'.
CHANGELOG_RELEASE_STRATEGY='delete'

# Make the release command create a commit with the changelog changes. Requires CHANGELOG_GIT_STAGE_RELEASE to be enabled as well.
CHANGELOG_RELEASE_COMMIT=true
CHANGELOG_RELEASE_COMMIT_MESSAGE="Version #VERSION#"

# Make the release command also create a tag on the newly created commit. Requires CHANGELOG_RELEASE_COMMIT to be enabled as well.
CHANGELOG_RELEASE_TAG=true

CHANGELOG_GIT_STAGE_RELEASE=true
CHANGELOG_GIT_STAGE_CHANGE=true

# Specify all allowed change types: Make sure to not include any empty lines.
CHANGELOG_ALLOWED_CHANGETYPES="Added
Changed
Deprecated
Removed
Fixed
Security"

#INTERNAL
CHANGELOG_MKTEMP_OPTIONS="--tmpdir changelog-sh-tmp.XXXXXXXX"
CHANGELOG_DIFF_OPTIONS="--color=always -u"