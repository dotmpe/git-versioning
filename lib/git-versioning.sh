#!/bin/bash
V_SH_SOURCED=$_
V_SH_MAIN=$0
V_SH_LIB=$BASH_SOURCE

# Id: git-versioning/0.0.28-dev lib/git-versioning.sh
# version: 0.0.28-dev git-versioning lib/git-versioning.sh

source $LIB/util.sh

version=0.0.28-dev # git-versioning

[ -n "$PREFIX" ] || {
  PREFIX=/usr/local
  V_SH_ROOT=$PREFIX/share/git-versioning
  LIB=$V_SH_ROOT/lib
  TOOLS=$V_SH_ROOT/lib
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


APP_ID=
VER_STR=
VER_MIN=

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
  [ -e .app-id ] && {
    APP_ID=$(cat .app-id)
    return
  }
  META_FILES=$(module_meta_list)
  for META_FILE in $META_FILES
  do
    if [ "${META_FILE:0:9}" = "package.y" ] || [ "$META_FILE" = "module.meta" ]
    then
      APP_ID=$(grep '^# git-versioning main:' $META_FILE | awk '{print $4}')
      [ -n "$APP_ID" ] && {
        break;
      } || {
        echo "Module with $META_FILE does not contain 'main:' entry,"  1>&2
        echo "looking further for APP_ID. "  1>&2
      }
    else if [ "${META_FILE:-5}" = ".json" ]
    then
      # assume first "name": key is package name, not some nested object
      APP_ID=$(grep '"name":' $META_FILE | sed 's/.*"name"[^"]*"\(.*\)".*/\1/')
      [ -n "$APP_ID" ] && {
        echo "$0: Unable to get APP_ID from $META_FILE 'name': key" 1>&2
      }
    fi; fi
  done
  [ -n "$APP_ID" ] || {
    APP_ID=$(basename $PWD)
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
    echo "Expected VER=$VER to equal STR=$STR" >&2
  }
}

loadVersion()
{
  doc=$1
  case $doc in

    *.rst )
      STR=`get_rst_field_main_version $doc`
      parse_version "$STR"
    ;;

    * )
      echo "$0: Unable load version from $doc"
      exit 2
    ;;

  esac
  #echo "Loaded version from $doc: $VER_STR"
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

  load_app_id

  [ -n "$APP_ID" ] || {
    echo "$0: Cannot get APP_ID from any metadata file. Aborting git-versioning. " 1>&2
    exit 3
  }

  V_PATH_LIST=$(cat $V_DOC_LIST)
  V_MAIN_DOC=$(head -n 1 $V_DOC_LIST)

  loadVersion $V_TOP_PATH/$V_MAIN_DOC

  buildVER
  #echo "Version set to $VER_STR"
}

source $LIB/formats.sh

getVersion()
{
  case $1 in

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

    *.mk | *Makefile )
      get_clike_comment_id $1 | while read STR;
      do echo "C-Like Comment: $STR"; done
      get_mk_var_version $1 | while read STR;
      do echo "MK Var: $STR"; done
    ;;

    *.sh | *configure )
      get_clike_comment_id $1 | while read STR;
      do echo "C-Like Comment: $STR"; done
      get_sh_var_version $1 | while read STR;
      do echo "SH Var: $STR"; done
    ;;

    * )
      echo "$0: Unable to retrieve version from $1"
      exit 2
    ;;

  esac

  unset doc
}

function apply_commonCLikeComment()
{
  apply_clike_comment_id $1
  apply_clike_comment_version $1
}

applyVersion()
{
  doc=$1
  case $doc in

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

    *.mk | *Makefile )
      apply_commonCLikeComment $doc
      apply_mk_var_version $doc
    ;;

    *.sh | *.bash | *configure | *.bats )
      apply_commonCLikeComment $doc
      apply_sh_var_version $doc
    ;;

    *.yaml | *.yml )
      apply_commonCLikeComment $doc
      apply_yaml_version $doc
    ;;

    *.json )
      apply_json_version $doc
    ;;

    *.js )
      apply_js_var_version $doc
    ;;

    *.coffee )
      apply_commonCLikeComment $doc
      apply_coffee_var_version $doc
    ;;

    *.properties )
      apply_commonCLikeComment $doc
      apply_properties_version $doc
    ;;

    *build.xml )
      apply_xml_comment_id $doc
      apply_ant_var_version $doc
    ;;

    * )
      echo "$0: Unable to version $doc"
      exit 2
    ;;

  esac

  echo "$doc @$VER_STR"

  unset doc
}

applyVersions()
{
  for doc in $V_PATH_LIST
  do
    applyVersion $doc
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
  echo "Checking all files for $VER_STR"
  # check without build meta
  $V_CHECK $V_DOC_LIST $(echo $VER_STR | awk -F+ '{print $1}')
  E=$?
  [ "$E" -eq "0" ] || return $(( 1 + $? ))
}

cmd_update()
{
  buildVER
  cmd_version
  applyVersions
}

cmd_increment()
{
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
  #applyVersions
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

cmd_get_version()
{
  getVersion $1
}

cmd_grep_version()
{
	branch=$1
	git grep '[^'
}

