#!/bin/bash

# Id: git-versioning/0.0.27-master lib/formats.sh

# reStructureText
function rst_field_version()
{
  VER_LINE=":\1ersion:\ $VER_STR ($APP_ID)"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^:\([Vv]\)ersion:.*'$APP_ID'.*$/'"$VER_LINE"'/' $P
}
function rst_field_id()
{
  ID_LINE=":Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^:Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
function rst_comment_id()
{
  ID_LINE=".. Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^\.\. Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
# Main version line has no further qualifier
function rst_field_main_version()
{
  VER_LINE=":Version:\ $VER_STR"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^:Version:.*/'"$VER_LINE"'/' $P
}

# C-like comments
function clike_comment_id()
{
  ID_LINE="# Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^# Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
function clike_comment_version()
{
  VER_LINE="# version: $VER_STR $APP_ID"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^#\ version:\ .* '$APP_ID'/'"$VER_LINE"'/' $P
}
commonCLikeComment()
{
  clike_comment_id $1
  clike_comment_version $1
}

# Sitefile
function sfrc_version()
{
  VER_LINE="\1\"sitefilerc\":\ \"$VER_STR\""
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^\([\ \t]*\)"sitefilerc":.*/'  "$VER_LINE"'/' $P
}
function sf_version()
{
  VER_LINE="sitefile:\ $VER_STR"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^sitefile:.*/'"$VER_LINE"'/' $P
}

# Makefile
function mk_var_version()
{
  VER_LINE="VERSION\1=\ $VER_STR#\ $APP_ID"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^VERSION\(\ *[?:]*\)=.*# '$APP_ID'/'"$VER_LINE"'/' $P
}
# FIXME function mk_var_id()
#{
#  VER_LINE="ID\1=\ $APP_ID\/$VER_STR"
#  P=$V_TOP_PATH/$1
#  sed_rewrite_tag 's/^ID\(\ *[?:]*\)=.*'$APP_ID'.*/'$VER_LINE'/' $P
#}

# Shell script
function sh_var_version()
{
  VER_LINE="version=$VER_STR\ #\ $APP_ID"
  P=$V_TOP_PATH/$1
  sed_rewrite_tag 's/^version=.* # '$APP_ID'/'"$VER_LINE"'/' $P
}

# YAML
function yaml_version()
{
  VER_LINE="version:\ $VER_STR\ #\ $APP_ID"
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^\([\ \t]*\)version:.* # '$APP_ID'/'"\1$VER_LINE"'/' $P > $P.out
  sed_post $P
}

# JSON
function json_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^\(.*\)"version":\ ".*"/\1"version":\ "'$VER_STR'"/' $P > $P.out
  sed_post $P
}
# JS
function js_var_version()
{
  VER_LINE="var version\ =\ '$VER_STR'; \/\/ $APP_ID"
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^var version =.* \/\/ '$APP_ID'/'"$VER_LINE"'/' $P > $P.out
  sed_post $P
}
# JS/Coffee-Script
function coffee_var_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^version =.* # '$APP_ID'/version\ =\ "'$VER_STR'"\ #\ '$APP_ID'/' $P > $P.out
  sed_post $P
}

# Java properties
function properties_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/^'$APP_ID'\.version=.*/'$APP_ID'.version='$VER_STR'/' $P > $P.out
  sed_post $P
}

function ant_var_version()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/<var\ name="'$APP_ID'\.version"\ value=".*"\ \/>/<var\ name="'$APP_ID'.version"\ value="'$VER_STR'"\ \/>/g' $P > $P.out
  sed_post $P
}

function xml_comment_id()
{
  P=$V_TOP_PATH/$1
  $sed_rewrite 's/<!--\ Id: '$APP_ID'\/.*\ -->/<!--\ Id:\ '$APP_ID'\/'$VER_STR'\ '$(echo $1 | sed 's/\//\\\//g')'\ -->/g' $P > $P.out
  sed_post $P
}
