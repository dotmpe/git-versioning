#!/usr/bin/env bash

# Install for non-dev environments

set -e

PREFIX=.
V_SH_SHARE=.

[ "$PREFIX" != "." ] || {
	echo "Cannot install, see configure. "
	exit 1
}


c_uninstall()
{
	echo "Running uninstall"
	# must be valid to proceed
	test -n "$V_SH_SHARE"
	test "$V_SH_SHARE" != "."
	test -e "$V_SH_SHARE"

	echo Removing $PREFIX/bin/git-versioning
	rm -vf $PREFIX/bin/git-versioning

	# prevent removing linked dir (strip trailing /)
	P=$(dirname $V_SH_SHARE)/$(basename $V_SH_SHARE)
	echo Removing $P..
	[ "$P" != "/" ] && rm -rfv $P
}

c_install()
{
	echo "Running install"
	test -n "$V_SH_SHARE"
	test ! -e "$V_SH_SHARE"
	mkdir -vp $V_SH_SHARE $PREFIX/bin || {
    stat $V_SH_SHARE $PREFIX/bin || {
    exit 41
  }
	cp -vr bin/ $V_SH_SHARE/bin
	cp -vr lib/ $V_SH_SHARE/lib
	cp -vr tools/ $V_SH_SHARE/tools
	chmod +x $V_SH_SHARE/tools/*/*.sh
	# TODO: make symlink relative
	ln -vs $V_SH_SHARE/bin/cli-version.sh $PREFIX/bin/git-versioning
	chmod +x $PREFIX/bin/git-versioning
}

func="c_$1"
( test -n "$1" && type $func &> /dev/null ) && {

	shift 1
	$func $@
	exit

} || {

	# auto-remove for existing install
	[ ! -e "$V_SH_SHARE" ] || c_uninstall
	c_install
	exit

}

# Id: git-versioning/0.0.27-master install.sh
