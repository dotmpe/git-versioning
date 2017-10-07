#!/bin/bash

# Id: git-versioning/0.1.4 lib/formats.sh

# reStructureText
RST_VER_TOKEN=':\([Vv]\)ersion:'
function apply_rst_field_version()
{
  P=$V_TOP_PATH/$1
  VER_LINE=":\1ersion:\ $VER_STR ($APP_ID)"
  sed_rewrite_tag 's/^'$RST_VER_TOKEN'.*'$APP_ID'.*$/'"$VER_LINE"'/' $P
}
function get_rst_field_version()
{
  grep '^'$RST_VER_TOKEN'.*('$APP_ID')' $1 | awk '{print $2}'
}
# Main version line has no further qualifier
function apply_rst_field_main_version()
{
  VER_LINE=":\1ersion:\ $VER_STR"
  sed_rewrite_tag 's/^'$RST_VER_TOKEN'.*/'"$VER_LINE"'/' $1
}
function get_rst_field_main_version()
{
  grep '^'$RST_VER_TOKEN'.*' $1 | awk '{print $2}'
}
#
function apply_rst_field_id()
{
  ID_LINE=":Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  sed_rewrite_tag 's/^:Id: '$APP_ID'.*/'"$ID_LINE"'/' $1
}
# Common Id line adapted to rSt comments
function apply_rst_comment_id()
{
  ID_LINE=".. Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  sed_rewrite_tag 's/^\.\. Id: '$APP_ID'.*/'"$ID_LINE"'/' $1
}
function get_rst_comment_id()
{
  DOC=$(echo $1 | sed 's/\//\\\//g')
  grep '^\.\. Id:\ '$APP_ID $1 | \
    sed 's/^.. Id: [^\/]*\/\([^\ ]*\).*$/\1/'
}

# C-like comments
function apply_unix_comment_id()
{
  ID_LINE="# Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^# Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
function get_unix_comment_id()
{
  sed -n 's/^# Id: [^\/]*\/\([^\ ]*\).*/\1/p' $1
}

function apply_unix_comment_version()
{
  VER_LINE="# version: $VER_STR $APP_ID"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^# version: .* '$APP_ID'/'"$VER_LINE"'/' $P
}
function get_unix_comment_version()
{
  sed -n 's/^# version: [^\/]*\/\([^\ ]*\).*/\1/p' $1
}

# Sitefile
function apply_sfrc_version()
{
  VER_LINE="\1\"sitefilerc\":\ \"$VER_STR\""
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^\([\ \t]*\)"sitefilerc":.*/'  "$VER_LINE"'/' $P
}
function apply_sf_version()
{
  VER_LINE="sitefile:\ $VER_STR"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^sitefile:.*/'"$VER_LINE"'/' $P
}

# Makefile
function apply_mk_var_version()
{
  VER_LINE="VERSION\1=\ $VER_STR#\ $APP_ID"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^VERSION\(\ *[?:]*\)=.*# '$APP_ID'/'"$VER_LINE"'/' $P
}

function get_mk_var_version()
{
  sed -n 's/^VERSION\ *[?:]= \([^\ ]*\)# .*/\1/p' $1
}

# FIXME function apply_mk_var_id()
#{
#  VER_LINE="ID\1=\ $APP_ID\/$VER_STR"
#  P=$V_TOP_PATH/$1
#  sed_rewrite_tag 's/^ID\(\ *[?:]*\)=.*'$APP_ID'.*/'$VER_LINE'/' $P
#}


# Generic var
function apply_var_version()
{
  test -n "$version_varname" || version_varname=version
  test -n "$version_quotes" && {
    VER_LINE="$version_varname\\1=\\1\'$VER_STR\'\ #\ $APP_ID"
  } || {
    VER_LINE="$version_varname\\1=\\1$VER_STR\ #\ $APP_ID"
  }
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^'$version_varname'\(\ *\)=.* # '$APP_ID'/'"$VER_LINE"'/' $P
}

# Shell script
function apply_sh_var_version()
{
  apply_var_version $1
}

function get_sh_var_version()
{
  grep '^version=.*' $1
}

# YAML
function apply_yaml_version()
{
  VER_LINE="version:\ $VER_STR\ #\ $APP_ID"
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^\([\ \t]*\)version:.* # '$APP_ID'/'"\1$VER_LINE"'/' $P > $P.out
  sed_post $P
}

# JSON
function apply_json_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^\(.*\)"version":\ ".*"/\1"version":\ "'$VER_STR'"/' $P > $P.out
  sed_post $P
}
# JS
function apply_js_var_version()
{
  VER_LINE="var version\ =\ '$VER_STR'; \/\/ $APP_ID"
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^var version =.* \/\/ '$APP_ID'/'"$VER_LINE"'/' $P > $P.out
  sed_post $P
}
# JS/Coffee-Script
function apply_coffee_var_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^version =.* # '$APP_ID'/version\ =\ "'$VER_STR'"\ #\ '$APP_ID'/' $P > $P.out
  sed_post $P
}

# Java properties
function apply_properties_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^'$APP_ID'\.version=.*/'$APP_ID'.version='$VER_STR'/' $P > $P.out
  sed_post $P
}

function get_properties_version()
{
  test -n "$2" || set -- "$1" "${APP_ID}.version"
  P=$V_TOP_PATH/$1
  grep '^'$2'=.*' $P
}

function apply_ant_var_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/<var\ name="'$APP_ID'\.version"\ value=".*"\ \/>/<var\ name="'$APP_ID'.version"\ value="'$VER_STR'"\ \/>/g' $P > $P.out
  sed_post $P
}

function apply_xml_comment_id()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/<!--\ Id: '$APP_ID'\/.*\ -->/<!--\ Id:\ '$APP_ID'\/'$VER_STR'\ '$(echo $1 | sed 's/\//\\\//g')'\ -->/g' $P > $P.out
  sed_post $P
}

function apply_clike_line_comment_id()
{
  ID_LINE="\/\/ Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  sed_rewrite_tag 's/^\/\/ Id: '$APP_ID'.*/'"$ID_LINE"'/' $1
}
function get_clike_line_comment_id()
{
  DOC=$(echo $1 | sed 's/\//\\\//g')
  grep '^\/\/ Id:\ '$APP_ID $1 | \
    sed 's/^.. Id: [^\/]*\/\([^\ ]*\).*$/\1/'
}

