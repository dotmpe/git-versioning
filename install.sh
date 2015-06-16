#!/bin/bash

V_SH_SHARE=/usr/local/share/git-versioning

function uninstall()
{
  test -n "$V_SH_SHARE"
  test -e "$V_SH_SHARE"
  rm -vf /usr/local/bin/git-versioning

  # prevent removing linked dir
  P=$(dirname $V_SH_SHARE)/$(basename $V_SH_SHARE)
  [ "$P" != "/" ] && rm -rfv $P
}

function install()
{
  test -n "$V_SH_SHARE"
  test ! -e "$V_SH_SHARE"
  mkdir -p $V_SH_SHARE/
  cp -vr bin/ $V_SH_SHARE/bin; chmod +x $V_SH_SHARE/bin/*
  cp -vr lib/ $V_SH_SHARE/lib
  cp -vr tools/ $V_SH_SHARE/tools; chmod +x $V_SH_SHARE/tools/*/*.sh
  ( cd /usr/local/bin/;pwd;ln -vs $V_SH_SHARE/bin/cli-version.sh git-versioning )
}


[ ! -e "$V_SH_SHARE" ] || uninstall

install

