#!/bin/bash

# Id: git-versioning/0.0.17 lib/formats.sh

# Main version line has no further qualifier
function rst_field_main_version()
{
  VER_LINE=":Version:\ $VER_STR"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^:Version:.*/'"$VER_LINE"'/' $P
}
function rst_field_version()
{
  VER_LINE=":Version:\ $VER_STR ($APP_ID)"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^:Version:.*'$APP_ID'.*$/'"$VER_LINE"'/' $P
}
function rst_field_id()
{
  ID_LINE=":Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^:Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
function rst_comment_id()
{
  ID_LINE=".. Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^\.\. Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}

function clike_comment_id()
{
  ID_LINE="# Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^# Id: '$APP_ID'.*/'"$ID_LINE"'/' $P
}
function clike_comment_version()
{
  VER_LINE="# version: $VER_STR $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^#\ version:\ .* '$APP_ID'/'"$VER_LINE"'/' $P
}
commonCLikeComment()
{
  clike_comment_id $1
  clike_comment_version $1
}


function sfrc_version()
{
  VER_LINE="\1\"sitefilerc\":\ \"$VER_STR\""
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^\([\ \t]*\)"sitefilerc":.*/'  "$VER_LINE"'/' $P
}
function sf_version()
{
  VER_LINE="sitefile:\ $VER_STR"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^sitefile:.*/'"$VER_LINE"'/' $P
}

# Makefile
function mk_var_version()
{
  VER_LINE="VERSION\1= $VER_STR# $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^VERSION\(\ *\)=.*# '$APP_ID'/'"$VER_LINE"'/' $P
}
function mk_var_id()
{
  VER_LINE="ID\1= $APP_ID/$VER_STR"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^.*ID\(\ *\)= '$APP_ID'.*/'"$VER_LINE"'/' $P
}

# Shell script
function sh_var_version()
{
  VER_LINE="version=$VER_STR # $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^version=.* # '$APP_ID'/'"$VER_LINE"'/' $P
}

# YAML
function yaml_version()
{
  VER_LINE="version:\ $VER_STR # $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^\([\ \t]*\)version:.* # '$APP_ID'/'"\1$VER_LINE"'/' $P
}

# JSON
function json_version()
{
  VER_LINE="\"version\":\ \"$VER_STR\","
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^\([\ \t]*\)"version":.*/\1'"$VER_LINE"'/' $P
}
function js_var_version()
{
  VER_LINE="var version\ =\ '$VER_STR'; \/\/ $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^var version =.* \/\/ '$APP_ID'/'"$VER_LINE"'/' $P
}
function coffee_var_version()
{
  VER_LINE="version = '$VER_STR' # $APP_ID"
  P=$V_TOP_PATH/$1
  sed -i .applyVersion-bak 's/^version =.* # '$APP_ID'/'"$VER_STR"'/' $P
}

