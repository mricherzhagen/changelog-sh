CHANGELOG_FILENAME='CHANGELOG.md'
CHANGELOG_HEADER="# What's new?
"
CHANGELOG_INCLUDE_TIMESTAMP=true

# CHANGELOG_RELEASE_STRATEGY controls what happens with the unreleased changefiles when an release is created.
# Can be either 'move' or 'delete'.
CHANGELOG_RELEASE_STRATEGY='delete'
CHANGELOG_GIT_STAGE_RELEASE=true

#INTERNAL
CHANGELOG_MKTEMP_OPTIONS="--tmpdir changelog-sh-tmp.XXXXXXXX"
CHANGELOG_DIFF_OPTIONS="--color=always -u"