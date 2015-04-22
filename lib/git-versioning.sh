#!/bin/bash
V_SH_SOURCED=$_
V_SH_MAIN=$0
V_SH_LIB=$BASH_SOURCE

# Id: git-versioning/0.0.15-dev+20150422-0230 lib/git-versioning.sh

source lib/util.sh

version=0.0.15-dev+20150422-0230 # git-versioning

[ -n "$V_TOP_PATH" ] || {
  V_TOP_PATH=.
}

[ -n "$V_DOC_LIST" ] || {
  V_DOC_LIST=$V_TOP_PATH/.versioned-files.list
}

[ -n "$V_CHECK" ] || {
  V_CHECK=$V_TOP_PATH/tools/version-check.sh
}

[ -n "$V_META_NAMES" ] || {
  V_META_NAMES="module.meta package.yaml package.yml package.json bower.json"
}

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
  META_FILES=$(module_meta_list)
  for META_FILE in $META_FILES
  do
    if [ "${META_FILE:0:9}" = "package.y" ] || [ "$META_FILE" = "module.meta" ]
    then
      APP_ID=$(grep '^main:' $META_FILE | awk '{print $2}')
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
     echo basename $PWD
  }
}

# Set git-versioning vars
load()
{
  [ "$V_SH_LIB" == "./lib/git-versioning.sh" ] || {
    echo "$0: This script should be named ./lib/git-versioning.sh"  1>&2
    echo "So that PWD is be the module metadata dir. "  1>&2
    echo "Untested usage: Aborting. "  1>&2
    exit 2
  }

  load_app_id

  [ -n "$APP_ID" ] || {
    echo "$0: Cannot get APP_ID from any metadata file. Aborting git-versioning. " 1>&2
    exit 3
  }

  V_PATH_LIST=$(cat $V_DOC_LIST)
  V_MAIN_DOC=$(head -n 1 $V_DOC_LIST)

  # XXX Expect rSt MAIN_DOC
  VER_TOKEN=":Version:"

  VER_STR=$(grep "^$VER_TOKEN" $V_TOP_PATH/$V_MAIN_DOC | awk '{print $2}')
 
  VER_MAJ=$(echo $VER_STR | awk -F. '{print $1}')
  VER_MIN=$(echo $VER_STR | awk -F. '{print $2}')
  VER_PAT=$(echo $VER_STR | awk -F. '{print $3}' \
    | awk -F- '{print $1}' | awk -F+ '{print $1}' )

  VER_TAGS=$(echo $VER_STR | awk -F- '{print $2}')
  VER_PRE=$(echo $VER_TAGS | awk -F+ '{print $1}')
  VER_META=$(echo $VER_TAGS | awk -F+ '{print $2}')
}

commonCLikeComment()
{
  VER_LINE="# version: $VER_STR $APP_ID"
  sed -i .applyVersion-bak 's/^#\ version:\ .* '$APP_ID'/'"$VER_LINE"'/' $V_TOP_PATH/$1

  [ -n "$APP_ID" ] || return;

  ID_LINE="# Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  sed -i .applyVersion-bak 's/^# Id: '$APP_ID'.*/'"$ID_LINE"'/' $V_TOP_PATH/$1
}

applyVersion()
{
  for doc in $V_PATH_LIST
  do
    case $doc in

      *.rst )
        if [ "$doc" = "$V_MAIN_DOC" ]
        then
          VER_LINE=":Version:\ $VER_STR"
          sed -i .applyVersion-bak 's/^:Version:.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
        fi
        ID_LINE=".. Id: $APP_ID\/$VER_STR "$(echo $doc | sed 's/\//\\\//g')
        sed -i .applyVersion-bak 's/^\.\. Id: '$APP_ID'.*/'"$ID_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.sitefilerc )
        VER_LINE="\1\"sitefilerc\":\ \"$VER_STR\""
        sed -i .applyVersion-bak 's/^\([\ \t]*\)"sitefilerc":.*/'  "$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *Sitefile.yaml | *Sitefile.yml  )
        VER_LINE="sitefile:\ $VER_STR"
        sed -i .applyVersion-bak 's/^sitefile:.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;

      *.mk | *Makefile )
        commonCLikeComment $doc
        VER_LINE="VERSION\1= $VER_STR # $APP_ID"
        sed -i .applyVersion-bak 's/^VERSION\(\ *\)=.* # '$APP_ID'/'"$VER_LINE"'/' $V_TOP_PATH/$doc
        ;;

      *.sh )
        commonCLikeComment $doc
        VER_LINE="version=$VER_STR # $APP_ID"
        sed -i .applyVersion-bak 's/^version=.* # '$APP_ID'/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.yaml | *.yml )
        commonCLikeComment $doc
        VER_LINE="version:\ $VER_STR # $APP_ID"
        sed -i .applyVersion-bak 's/^\([\ \t]*\)version:.* # '$APP_ID'/'"\1$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.js )
        VER_LINE="var version\ =\ '$VER_STR'; \/\/ $APP_ID"
        sed -i .applyVersion-bak 's/^var version =.* \/\/ '$APP_ID'/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.json )
        VER_LINE="\"version\":\ \"$VER_STR\","
        sed -i .applyVersion-bak 's/^\([\ \t]*\)"version":.*/\1'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.coffee )
        commonCLikeComment $doc
        VER_LINE="version = '$VER_STR' # $APP_ID"
        sed -i .applyVersion-bak 's/^version =.* # '$APP_ID'/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;

      * )
        echo "$0: Unable to version $doc"
        exit 2;;

    esac

    rm $V_TOP_PATH/$doc.applyVersion-bak

    echo "$doc @$VER_STR"

  done
}

buildVER()
{
  VER_STR=$VER_MAJ"."$VER_MIN"."$VER_PAT
  [ -z "$VER_PRE" ] || {
    VER_STR=$VER_STR-$VER_PRE
  }
  [ -z "$VER_META" ] || {
    VER_STR=$VER_STR+$VER_META
  }
}

incrVMAJ()
{
  let VER_MAJ++
  VER_MIN=0
  VER_PAT=0
  VER_PRE=
  VER_META=
  buildVER
  applyVersion
}

incrVMIN()
{
  let VER_MIN++
  VER_PAT=0
  VER_PRE=
  VER_META=
  buildVER
  applyVersion
}

incrVPAT()
{
  let VER_PAT++
  VER_PRE=
  VER_META=
  buildVER
  applyVersion
}

cmd_check()
{
  buildVER
  cmd_version
  # check without build meta
  $V_CHECK $V_DOC_LIST $(echo $VER_STR | awk -F+ '{print $1}')
  E=$?
  [ "$E" -eq "0" ] || return $(( 1 + $? ))
}

cmd_update()
{
  buildVER
  cmd_version
  applyVersion
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
  VER_PRE=$(echo $* | tr ' ' '.')
  cmd_update
}
cmd_release=release
cmd_pre_release=release

build()
{
  VER_META=$(echo $* | tr ' ' '.')
  cmd_update
}
cmd_build=build

cmd_info()
{
  echo "Application name/version: "$(cmd_app_id)" (using git-versioning/$version)"
}

cmd_help()
{
  echo $(cmd_app_id)
  echo 'Usage:'
  echo 'cli-version [info]                 Print git-version application Id. '
  echo 'cli-version version                Print local version. '
  echo 'cli-version name                   Print local application name. '
  echo 'cli-version app-id                 Print local application Id (name/version). '
  echo 'cli-version update                 Update files with embedded version. '
  echo 'cli-version increment [min [maj]]  Increment patch/min/maj version. '
  echo 'cli-version [pre-]release tag[s..] Mark version with (pre-)release tag(s). '
  echo "cli-version dev [tags..]           pre-release with default 'dev' tag. "
  echo "cli-version testing [tags..]       pre-release with default 'alpha' tag. "
  echo "cli-version unstable [tags..]      pre-release with default 'beta' tag. "
  echo 'cli-version build meta[..]         Mark version with build meta tag(s). '
  echo 'cli-version snapshot               set build-meta to datetime tag. '
  echo 'cli-version snapshot-s             set build-meta to epoch timestamp tag. '
  echo 'cli-version check                  Verify version embedded files. '
  echo 'cli-version [help|*]               Print this usage. '
}

cmd_app_id()
{
  echo $APP_ID/$VER_STR
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
  cmd_build $(date +%s) $*
}

