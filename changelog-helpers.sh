#!/bin/bash

function _changelogsh_title {
  input=$1
  echo $(echo ${input:0:1} | tr  '[a-z]' '[A-Z]')${input:1}
}

function _changelogsh_raw_to_expanded {
  input="$1"
  split=("${input//./ }")
  echo $split | xargs printf '%03d'
}

function _changelogsh_expanded_to_raw {
  input=$1
  split=($(echo $input | fold -w3))

  echo $split | sed 's/^0*//g; s/ 0*/./g'
}

function _changelogsh_is_semver {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-.+)?$'
    return $?
}

function _changelogsh_force_semver {
  if [ $CHANGELOGSH_FORCE_SEMVER = true ] && ! _changelogsh_is_semver $1; then
    >&2 echo "ERROR: $1 is not a semantic version number and CHANGELOGSH_FORCE_SEMVER is enabled."
    exit 1;
  fi
}

function _changelogsh_get_latest_version {
  echo "`sed -n -E 's/^## \[(.+)\].*$/\1/p' CHANGELOG.md | head -n1`"
  return
  if [ -z "${CHANGELOGSH_LATEST_VERSION_CACHE+x}" ]; then
    CHANGELOGSH_LATEST_VERSION_CACHE="`sed -n -E 's/^## \[(.+)\].*$/\1/p' CHANGELOG.md | head -n1`"
  fi
  echo "$CHANGELOGSH_LATEST_VERSION_CACHE"
}

function _changelogsh_check_new_version_gt {
  if [ $CHANGELOGSH_CHECK_VERSION_GT = true ]; then
      local latestVersion
      # Code from https://unix.stackexchange.com/a/278377/50708
      latestVersion="`_changelogsh_get_latest_version`"
      if [ "$latestVersion" != "" ] && ! _changelogsh_compare_semver_gt "$1" "$latestVersion"; then
          if [ $CHANGELOGSH_FORCE_VERSION_GT = true ]; then
              >&2 echo "ERROR: $1 is not larger than the latest version $latestVersion."
              exit 1
          else
              read -p "The version number $1 is not larger than the latest version $latestVersion. Continue anyway? [y/N] " -r
              if ! [ "$REPLY" = "y" -o "$REPLY" = "yes" ]; then
                  exit 1;
              fi
              export CHANGELOGSH_CHECK_VERSION_GT=false
              return 1
          fi
      fi
  fi
}

# Return 0/true when $1 > $2
function _changelogsh_compare_semver_gt {
  _changelogsh_compare_versions "$1" "$2"
  [ $? -eq 1 ]
  return $?
}


# Code from https://stackoverflow.com/a/49351294/2256700
# Compare two version strings [$1: version string 1 (v1), $2: version string 2 (v2)]
# Return values:
#   0: v1 == v2
#   1: v1 > v2
#   2: v1 < v2
# Based on: https://stackoverflow.com/a/4025065 by Dennis Williamson
function _changelogsh_compare_versions() {

    # Trivial v1 == v2 test based on string comparison
    [[ "$1" == "$2" ]] && return 0

    # Local variables
    local regex="^(.*)-r([0-9]*)$" va1=() vr1=0 va2=() vr2=0 len i IFS="."

    # Split version strings into arrays, extract trailing revisions
    if [[ "$1" =~ ${regex} ]]; then
        va1=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr1=${BASH_REMATCH[2]}
    else
        va1=($1)
    fi
    if [[ "$2" =~ ${regex} ]]; then
        va2=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr2=${BASH_REMATCH[2]}
    else
        va2=($2)
    fi

    # Bring va1 and va2 to same length by filling empty fields with zeros
    (( ${#va1[@]} > ${#va2[@]} )) && len=${#va1[@]} || len=${#va2[@]}
    for ((i=0; i < len; ++i)); do
        [[ -z "${va1[i]}" ]] && va1[i]="0"
        [[ -z "${va2[i]}" ]] && va2[i]="0"
    done

    # Append revisions, increment length
    va1+=($vr1)
    va2+=($vr2)
    len=$((len+1))

    # *** DEBUG ***
    #echo "TEST: '${va1[@]} (?) ${va2[@]}'"

    # Compare version elements, check if v1 > v2 or v1 < v2
    for ((i=0; i < len; ++i)); do
        if (( 10#${va1[i]} > 10#${va2[i]} )); then
            return 1
        elif (( 10#${va1[i]} < 10#${va2[i]} )); then
            return 2
        fi
    done

    # All elements are equal, thus v1 == v2
    return 0
}

function _changelogsh_split_semver {
  echo "$1" | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)(-.+)?$/\1 \2 \3 \4/'
}

function _changelogsh_get_next_version {
  local version_split=(`_changelogsh_split_semver "$1"`)
  case "$2" in
    'major')
      echo "`expr "${version_split[0]}" + 1`.0.0"
      ;;
    'minor')
      echo "${version_split[0]}.`expr "${version_split[1]}" + 1`.0"
      ;;
    'patch')
      echo "${version_split[0]}.${version_split[1]}.`expr "${version_split[2]}" + 1`"
      ;;
  esac
}

function _changelogsh_parse_version_arg {
  if [[ "$1" =~ ^bump- ]]; then
    local latestVersion="`_changelogsh_get_latest_version`"
  fi
  case "$1" in
    bump-major)
      echo "`_changelogsh_get_next_version "$latestVersion" "major"`"
      ;;
    bump-major-*)
      echo "`_changelogsh_get_next_version "$latestVersion" "major"`-${1#bump-major-}"
      ;;
    bump-minor)
      echo "`_changelogsh_get_next_version "$latestVersion" "minor"`"
      ;;
    bump-minor-*)
      echo "`_changelogsh_get_next_version "$latestVersion" "minor"`-${1#bump-minor-}"
      ;;
    bump-patch)
      echo "`_changelogsh_get_next_version "$latestVersion" "patch"`"
      ;;
    bump-patch-*)
      echo "`_changelogsh_get_next_version "$latestVersion" "patch"`-${1#bump-patch-}"
      ;;
    *)
      echo "$1"
    esac
}