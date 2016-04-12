#!/bin/bash
V_SH_SOURCED=$_
V_SH_MAIN=$0
V_SH_LIB=$BASH_SOURCE

set -e


# Id: git-versioning/0.0.31-dev+20160412-1532 lib/git-versioning.sh
# version: 0.0.31-dev+20160412-1532 git-versioning lib/git-versioning.sh

source $LIB/util.sh

version=0.0.31-dev+20160412-1532 # git-versioning

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
  # TODO: Deprecate: app-id dotfile
  test ! -e .app-id || {
    APP_ID=$(cat .app-id)
    note "Deprecated: Loaded APP_ID=$APP_ID from ./.app-id "
    return
  }

  # XXX: would need some mime header parser.
  # probably keep using first row from doc list
  # or mark table entry
  #test ! -e .version-attributes || {
  #  APP_ID=$(get_mime_header "$doc" "App-Id")
  #  V_MAIN_DOC=$(get_mime_header "$doc" "Main-File")
  #  test -n "$APP_ID" && return
  #}

  # Second option: use common metadata file (ie. bower.json, package.json, or a
  # generic YAML metadata package).
  # For YAML, expect a comment sentinel with '# git-versioning main: <app-id>'
  # XXX: Why not use comment on the line?
  # XXX: For JSON, take any "name" key.
  META_FILES=$(module_meta_list)
  for META_FILE in $META_FILES
  do
    if [ "${META_FILE:0:9}" = "package.y" ] || [ "$META_FILE" = "module.meta" ]
    then
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

  verbosity=0 getVersion "$doc" >/dev/null || return

  case "$doc" in

    *.properties )
      STR=`get_properties_version $doc `
      parse_version "$STR"
    ;;

    *.rst )
      STR=`get_rst_field_main_version $doc $key`
      parse_version "$STR"
    ;;

    * )
      err "$0: Unable load version from '$1'" 2
    ;;

  esac

  unset doc
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

  [ -n "$APP_ID" ] || {
    load_app_id || return
  }

  [ -n "$APP_ID" ] || {
    err "Cannot get APP_ID from any metadata file. Aborting git-versioning. " 3
  }

  test -n "$VER_STR" && {
    log "Using provided version: $VER_STR"
    test -e "$V_DOC_LIST" || {
      log "No V_DOC_LIST ($V_DOC_LIST), using stdin "
      V_DOC_LIST="-"
    }
  } || {
    # Load version from main document
    test -n "$V_MAIN_DOC" || V_MAIN_DOC=$(head -n 1 $V_DOC_LIST)

    test -n "$V_MAIN_DOC" || \
      err "Cannot get main document. " 3

    test -e "$V_TOP_PATH/$V_MAIN_DOC" || \
      err "Main document does not exist. " 3

    loadVersion "$V_TOP_PATH/$V_MAIN_DOC"

    buildVER

    log "Loaded version from $V_TOP_PATH/$V_MAIN_DOC: $VER_STR"
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

source $LIB/formats.sh

getVersion()
{
  case "$1" in

    *.rst )

      if [ "$1" = "$V_MAIN_DOC" ]
      then

        get_rst_field_main_version $1 | while read STR
        do echo "rSt Field Version (Main): $STR"; done

      fi

      get_rst_comment_id $1 | while read STR
      do echo "rSt Comment Id: $STR"; done

      get_rst_field_version $1 | while read STR
      do echo "rSt Field Version: $STR"; done

    ;;

    *.mk | *Makefile* )
      get_unix_comment_id $1 | while read STR;
      do echo "C-Like Comment: $STR"; done
      get_mk_var_version $1 | while read STR;
      do echo "MK Var: $STR"; done
    ;;

    *.sh | *.bash | *configure | *.bats )
      get_unix_comment_id $1 | while read STR;
      do echo "C-Like Comment: $STR"; done
      get_sh_var_version $1 | while read STR;
      do echo "SH Var: $STR"; done
    ;;

    * )
      echo "$0: Unable to retrieve version from $1"
      exit 2
    ;;

  esac
}

function apply_commonUnixComment()
{
  apply_unix_comment_id $1
  apply_unix_comment_version $1
}

applyVersion()
{
  local doc="$1"
  case "$doc" in

    *.rst )
      if [ "$doc" = "$V_MAIN_DOC" ]
      then
        apply_rst_field_main_version $doc
      else
        apply_rst_field_version $doc
      fi
      apply_rst_field_id $doc
      apply_rst_comment_id $doc
    ;;

    *.sitefilerc )
      apply_sfrc_version $doc
    ;;

    *Sitefile*.yaml | *Sitefile*.yml )
      apply_sf_version $doc
    ;;

    *.mk | *Makefile* )
      apply_commonUnixComment $doc
      apply_mk_var_version $doc
    ;;

    *.sh | *.bash | *configure | *.bats )
      apply_commonUnixComment $doc
      apply_sh_var_version $doc
    ;;

    *.yaml | *.yml )
      apply_commonUnixComment $doc
      apply_yaml_version $doc
    ;;

    *.json )
      apply_json_version $doc
    ;;

    *.js )
      apply_clike_line_comment_id $doc
      apply_js_var_version $doc
    ;;

    *.coffee )
      apply_commonUnixComment $doc
      apply_coffee_var_version $doc
    ;;

    *.properties )
      apply_commonUnixComment $doc
      apply_properties_version $doc
    ;;

    *build.xml )
      apply_xml_comment_id $doc
      apply_ant_var_version $doc
    ;;

    *.jade | *.styl | *.pde | *.ino )
      apply_clike_line_comment_id $doc
    ;;

    * )
      # FIXME: git-versioning could just replace if tag is detailed enough (ie.
      # snapshot), or if forced to (or if there's no need to watch other embedded versions).
      echo "$0: Unable to version $doc"
      exit 2
    ;;

  esac

  echo "$doc @$VER_STR"

  unset doc
}

applyVersions()
{
  local doc
  read_doc_list | while read doc
  do
    applyVersion "$doc"
  done
  unset doc
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
  log "Checking all files for $VER_STR"
  log "Using $V_CHECK"
  # check without build meta
  cat $V_DOC_LIST | . $V_CHECK $(echo $VER_STR | awk -F+ '{print $1}') || {
    return $(( 1 + $? ))
  }
}

cmd_update()
{
  buildVER
  cmd_validate >> /dev/null || return 1
  cmd_version
  applyVersions
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
    && log "$VER_STR ok" \
    || err "Not a valid semver: '$VER_STR'"
}

