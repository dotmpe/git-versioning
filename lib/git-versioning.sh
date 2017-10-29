#!/bin/bash
V_SH_SOURCED=$_
V_SH_MAIN=$0
V_SH_LIB=$BASH_SOURCE

set -e


# Id: git-versioning/0.2.7-dev lib/git-versioning.sh
# version: 0.2.7-dev git-versioning lib/git-versioning.sh

source $LIB/util.sh

version=0.2.7-dev # git-versioning

[ -n "$V_SH_SHARE" ] || {
  [ -n "$PREFIX" ] || {
    PREFIX=/usr/local
  }
  V_SH_SHARE=$PREFIX/share/git-versioning
  LIB=$V_SH_SHARE/lib
  TOOLS=$V_SH_SHARE/tools
}

# Path to versioned files
[ -n "$V_TOP_PATH" ] || {
  V_TOP_PATH=.
}

# Configuration file listing file path under versioning (with embedded version)
# first file is main file, used to determine current version
[ -n "$V_DOC_LIST" ] || {
  V_DOC_LIST=$V_TOP_PATH/.versioned-files.list
}

# XXX External script to verify version
[ -n "$V_CHECK" ] || {
  [ -e "$V_TOP_PATH/tools/cmd/version-check.sh" ] && {
    V_CHECK=$V_TOP_PATH/tools/cmd/version-check.sh
  } || {
    V_CHECK=$TOOLS/cmd/version-check.sh
  }
}

# Names of files tried to get app-name from
[ -n "$V_META_NAMES" ] || {
  V_META_NAMES="module.meta package.yaml package.yml package.json bower.json"
}

# Format used for snapshot command
[ -n "$V_SNAPSHOT_DATE_FMT" ] || {
  V_SNAPSHOT_DATE_FMT=%Y%m%d-%H%M
}



# Determine package metafile
module_meta_list() # $one
{
  for name in $V_META_NAMES
  do
    [ ! -e "./$name" ] || { echo $name; [ "$1" ] && return; }
  done
}

load_app_id()
{
  test ! -e .app-id || {
    APP_ID=$(cat .app-id)
    return
  }

  # Second option: use common metadata file (ie. bower.json, package.json, or a
  # generic YAML metadata package).
  # For YAML, expect a comment sentinel with '# git-versioning main: <app-id>'
  # XXX: Might use comment on the same line as version, but would need to review
  # regexes for all formats.
  # XXX: For JSON, take any "name" key. Works for package.json.
  META_FILES=$(module_meta_list)
  for META_FILE in $META_FILES
  do
    if [ "${META_FILE:0:9}" = "package.y" ] || [ "$META_FILE" = "module.meta" ]
    then
      # Scan for the main project ID, the one that determines the principle
      # version of the package.
      APP_ID=$(grep '^# git-versioning main:' $META_FILE | awk '{print $4}')
      [ -n "$APP_ID" ] && {
        break;
      } || {
        err "Module with $META_FILE does not contain 'main:' entry,"
      }
    else if [ "${META_FILE:-5}" = ".json" ]
    then
      # assume first "name": key is package name, not some nested object
      APP_ID=$(grep '"name":' $META_FILE | sed 's/.*"name"[^"]*"\(.*\)".*/\1/')
      [ -n "$APP_ID" ] && {
        err "$0: Unable to get APP_ID from $META_FILE 'name': key"
      }
    fi; fi
  done

  # Last resort, try to use the basename of the checkout directory
  [ -n "$APP_ID" ] || {
    APP_ID=$(basename $PWD)
    err "Warning: using directory basename for project name (APP_ID/.app-id) . "
  }
}

# 1:doc
parse_version()
{
  STR="$1"

  sed_ext="sed -r"
  [ "$(uname -s)" = "Darwin" ] && sed_ext="sed -E"

  VER_MAJ=$(echo $STR | $sed_ext 's/^([^\.]+).*$/\1/' )
  VER_MIN=$(echo $STR | $sed_ext 's/^[^\.]*\.([^\.]+).*$/\1/' )
  VER_PAT=$(echo $STR | $sed_ext 's/^[^\.]*\.[^\.]*\.([^+-]+).*$/\1/' )

  VER_TAGS=$(echo $STR | $sed_ext 's/^[0-9\.]*//' )
  VER_PRE=$(echo $VER_TAGS | $sed_ext 's/^-?([^+]*)(\+.*)?$/\1/' )
  VER_META=$(echo $VER_TAGS | $sed_ext 's/^([^+]*)\+?(.*)$/\2/' )

  VER=`concatVersion`
  [ "$VER" = "$STR" ] || {
    err "Expected VER=$VER to equal STR=$STR"
  }
}

loadVersion()
{
  test -n "$1" || return 1
  local doc="$1"

  case "$doc" in

    *.properties )
        STR=`get_properties_version $doc `
        parse_version "$STR"
      ;;

    *.rst )
        STR=`get_rst_field_main_version $doc $key`
        parse_version "$STR"
      ;;

    *.md )
        STR=`get_md_field_main_version $doc $key`
        parse_version "$STR"
      ;;

    * )
        err "$0: Unable load version from '$1'" 2
      ;;

  esac

  unset doc
}

main_doc()
{
  read_nix_style_file $1 | head -n 1
}

# Set git-versioning vars
load()
{
  [ "$(basename $V_SH_LIB)" == "git-versioning.sh" ] || {
    echo "$0: This script should be named ./lib/git-versioning.sh"  1>&2
    echo "So that PWD is be the module metadata dir. "  1>&2
    echo "Untested usage: Aborting. "  1>&2
    echo "Found V_SH_LIB=$V_SH_LIB"  1>&2
    exit 2
  }

  # Load/override settings from version-attributes
  test ! -e .version-attributes || {

    export_property .version-attributes File-List V_DOC_LIST
    export_property .version-attributes App-Id APP_ID
    export_property .version-attributes Main-File V_MAIN_DOC
    export_property .version-attributes Other-Files V_DOC_LIST_FILES
    export_property .version-attributes Version VER_STR
  }

  test -n "$APP_ID" || {
    load_app_id || return $?
  }

  test -n "$APP_ID" || {
    err "Cannot get APP_ID from any metadata file. Aborting git-versioning. " 3
  }

  test -e "$V_DOC_LIST" || {
    test -n "$V_DOC_LIST_FILES" && {
      echo $V_MAIN_DOC $V_DOC_LIST_FILES | tr ' ' '\n' > $V_DOC_LIST
    } || {

      warn "No V_DOC_LIST ($V_DOC_LIST), using stdin "
      V_DOC_LIST="-"
    }
  }

  test -n "$VER_STR" && {
    note "Using provided version: $VER_STR"
  } || {

    # Load version from main document
    test -n "$V_MAIN_DOC" || V_MAIN_DOC=$(main_doc $V_DOC_LIST)
    test -n "$V_MAIN_DOC" || err "Cannot get main document. " 3
    test -e "$V_TOP_PATH/$V_MAIN_DOC" || err "Main document does not exist. " 3

    loadVersion "$V_TOP_PATH/$V_MAIN_DOC"
    buildVER

    info "Loaded version from $V_TOP_PATH/$V_MAIN_DOC: $VER_STR"
  }
}

read_doc_version()
{
  test -e "$path" || return 1
}

read_doc_list()
{
  read_nix_style_file $V_DOC_LIST | while read path key
  do
    is_glob "$path" && {
      for _path in $path
      do
        echo $_path
        # TODO: read_doc_version $_path $key || err "doc version" 1
      done
    } || {
      echo $path
      # read_doc_version $path $key || err "doc version" 1
    }
  done
}

test ! -e .version-attributes ||
  formats=$(get_property .version-attributes Formats)
test -n "$formats" && {
  test -e "$formats" && {
    source $formats
  } || {
    stderr error "No formats file '$formats'" 1
  }
} || {
  source $LIB/formats.sh
}

test ! -e .version-attributes ||
  local_formats=$(get_property .version-attributes Local-Formats)
test -n "$local_formats" -a -e "$local_formats" && {
  stderr info "Including local formats from $local_formats"
  source $local_formats
}

getVersion()
{
  func_exists getVersion_local && {
    getVersion_local "$@" && return 0
  }
  getVersion_lib "$@"
}

function apply_commonUnixComment()
{
  apply_unix_comment_id $1
  apply_unix_comment_version $1
}

applyVersion()
{
  func_exists applyVersion_local && {
    applyVersion_local "$@"
  } || {
    applyVersion_lib "$@" && return || return $?
  }
}

applyVersions()
{
  local doc fail
  read_doc_list | while read doc
  do
    applyVersion "$doc" && {
      stderr info "Applied version to '$doc'"
    } || {
      stderr error "Failed applying version to '$doc'"
      fail=1
    }
  done
  unset doc
  trueish "$fail" && return 1 || return 0
}

concatVersion()
{
  STR=$VER_MAJ"."$VER_MIN"."$VER_PAT
  [ -z "$VER_PRE" ] || {
    STR=$STR-$VER_PRE
  }
  [ -z "$VER_META" ] || {
    STR=$STR+$VER_META
  }
  echo $STR
  unset STR
}

buildVER()
{
  VER_STR=$(concatVersion)
}

incrVMAJ()
{
  let VER_MAJ++
  VER_MIN=0
  VER_PAT=0
  VER_PRE=
  VER_META=
  buildVER
  applyVersions
}

incrVMIN()
{
  let VER_MIN++
  VER_PAT=0
  VER_PRE=
  VER_META=
  buildVER
  applyVersions
}

incrVPAT()
{
  let VER_PAT++
  VER_PRE=
  VER_META=
  buildVER
  applyVersions
}

cmd_check()
{
  cmd_validate >> /dev/null || return 1
  note "Checking all files for $VER_STR"
  info "Using $V_CHECK"
  # check without build meta
  cat $V_DOC_LIST | grep -v '^#' \
    | . $V_CHECK $(echo $VER_STR | awk -F+ '{print $1}') || {
      return $(( 1 + $? ))
  }
}

cmd_update()
{
  buildVER
  cmd_validate >> /dev/null || return 1
  applyVersions &&
    stderr note "Version succesfully applied" ||
    stderr err "Error applying version" 1
}

cmd_increment()
{
  cmd_validate >> /dev/null || return 1
  trueish $1 && {
    trueish $2 && {
      incrVMAJ
    } || {
      incrVMIN
    }
  } || {
    incrVPAT
  }
}

release()
{
  #cmd_update
  VER_PRE=$(echo $* | tr ' ' '.')
  echo "Setting pre-release to '$VER_PRE'"
  #concatVersion
  buildVER
  #VER_STR=`parse_version "$STR"`
  parse_version "$STR" | read VER_STR
  echo VER_STR:$VER_STR
  #cmd_version
  applyVersions
}

build()
{
  VER_META=$(echo $* | tr ' ' '.')
  echo "Setting build-meta to '$VER_META'"
  cmd_update
}

cmd_info()
{
  echo "Application name/version: "$(cmd_app_id)" (using git-versioning/$version)"
}

cmd_path()
{
  echo "Prefix: $PREFIX"
  echo "Shared files: $V_SH_ROOT"
  echo "Lib: $LIB"
  echo "Tools: $TOOLS"
}

cmd_help()
{
  echo $(cmd_app_id)
  echo 'Usage: '
  echo '  project-dir $ git-versioning <command> [<args>..]'
  echo 'Commands: '
  echo '  version                Print local version. '
  echo '  id|name                Print local application name (project). '
  echo '  app-id                 Print local application Id (name/version). '
  echo '  update                 Update files with embedded version. '
  echo '  increment [min [maj]]  Increment patch/min/maj version. '
  echo '  [pre-]release <tags>.. Mark version with (pre-)release tag(s). '
  echo "  dev [<tags>..]         pre-release with default 'dev' tag. "
  echo "  testing [<tags>..]     pre-release with default 'alpha' tag. "
  echo "  unstable [<tags>..]    pre-release with default 'beta' tag. "
  echo '  build meta[..]         Mark version with build meta tag(s). '
  echo '  snapshot               set build-meta to datetime tag. '
  echo '  snapshot-s             set build-meta to epoch timestamp tag. '
  echo '  validate               Validate syntax of version string from main file. '
  echo '  check                  Verify version embedded files. '
  echo '  info|path              Print git-versioning version, or paths. '
  echo '  [help|*]               Print this git-versioning usage guide. '
}

cmd_app_id()
{
  echo $APP_ID/$VER_STR
}

cmd_id()
{
  echo $APP_ID
}
cmd_name()
{
  echo $APP_ID
}

cmd_version()
{
  echo $VER_STR
}

# Some shortcuts to release/build

cmd_dev()
{
  release dev $*
}

cmd_testing()
{
  release alpha $*
}

cmd_unstable()
{
  release beta $*
}

cmd_snapshot()
{
  build $(date "+$V_SNAPSHOT_DATE_FMT") $*
}

# seconds since epoch
cmd_snapshot_s()
{
  build $(date +%s) $*
}

# XXX get/update specific versions from a file?
cmd_get_version()
{
  getVersion $1
}

V_GREP_PAT='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'

cmd_validate()
{
  echo $VER_STR | grep -E $V_GREP_PAT >> /dev/null \
    && note "$VER_STR ok" \
    || err "Not a valid semver: '$VER_STR'"
}
