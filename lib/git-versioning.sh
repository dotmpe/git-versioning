#!/bin/bash

source lib/util.sh

[ -n "$V_TOP_PATH" ] || {
  V_TOP_PATH=.
}

[ -n "$V_DOC_LIST" ] || {
  V_DOC_LIST=$V_TOP_PATH/.versioned-files.list
}

[ -n "$V_CHECK" ] || {
  V_CHECK=$V_TOP_PATH/tools/version-check.sh
}

# git-versioning package version
version=0.0.6-master

load()
{
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

applyVersion()
{
  for doc in $V_PATH_LIST
  do
    case $doc in

      *ReadMe.rst )
        VER_LINE=":Version:\ $VER_STR"
        sed -i .applyVersion-bak 's/^:Version:.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.sitefilerc )
        VER_LINE="\"sitefilerc\":\ \"$VER_STR\""
        sed -i .applyVersion-bak 's/^\ \ "sitefilerc":.*/'  "$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *Sitefile.yaml | *Sitefile.yml  )
        VER_LINE="sitefile:\ $VER_STR"
        sed -i .applyVersion-bak 's/^sitefile:.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;

      *.sh )
        VER_LINE="version=$VER_STR"
        sed -i .applyVersion-bak 's/^version=.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.yaml | *.yml )
        VER_LINE="version:\ $VER_STR"
        sed -i .applyVersion-bak 's/^  version:.*/'"  $VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.js )
        VER_LINE="var version\ =\ '$VER_STR';"
        sed -i .applyVersion-bak 's/^var version =.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.json )
        VER_LINE="\"version\":\ \"$VER_STR\","
        sed -i .applyVersion-bak 's/^\ \ "version":.*/  '"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;
      *.coffee )
        VER_LINE="version\ =\ '$VER_STR'"
        sed -i .applyVersion-bak 's/^version =.*/'"$VER_LINE"'/' $V_TOP_PATH/$doc
      ;;

      * ) echo $0 Unable to version $doc;
      ;;

    esac

    rm $V_TOP_PATH/$doc.applyVersion-bak

    echo "$doc @$VER_STR"

  done
  # for post-commit: git commit -m "version update: "$VER_STR
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

version()
{
  echo $VER_STR
}

check()
{
  buildVER
  version
  $V_CHECK $V_DOC_LIST $VER_STR
}

update()
{
  buildVER
  version
  applyVersion
}

increment()
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

pre-release()
{
  VER_PRE=$(echo $* | tr ' ' '.')
  update
}

build()
{
  VER_META=$(echo $* | tr ' ' '.')
  update
}
