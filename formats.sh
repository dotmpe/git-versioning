#!/bin/bash

# Id: git-versioning/0.0.16-master formats.sh

# Main version line has no further qualifier
function rst_field_main_version()
{
  VER_LINE=":Version:\ $2"
  sed -i .applyVersion-bak 's/^:Version:.*/'"$VER_LINE"'/' $1
}
function rst_field_version()
{
  VER_LINE=":Version:\ $2 ($3)"
  sed -i .applyVersion-bak 's/^:Version:.*'$3'.*$/'"$VER_LINE"'/' $1
}
function rst_field_id()
{
  ID_LINE=":Id: $3\/$2 "$(basename $1 | sed 's/\//\\\//g')
  sed -i .applyVersion-bak 's/^:Id: '$3'.*/'"$ID_LINE"'/' $1
}
function rst_comment_id()
{
  ID_LINE=".. Id: $3\/$2 "$(basename $1 | sed 's/\//\\\//g')
  sed -i .applyVersion-bak 's/^\.\. Id: '$3'.*/'"$ID_LINE"'/' $1
}
function sfrc_version()
{
  VER_LINE="\1\"sitefilerc\":\ \"$2\""
  sed -i .applyVersion-bak 's/^\([\ \t]*\)"sitefilerc":.*/'  "$VER_LINE"'/' $1
}
function sf_version()
{
  VER_LINE="sitefile:\ $2"
  sed -i .applyVersion-bak 's/^sitefile:.*/'"$VER_LINE"'/' $1
}
function mk_var_version()
{
  VER_LINE="VERSION\1= $2 # $3"
  sed -i .applyVersion-bak 's/^VERSION\(\ *\)=.* # '$3'/'"$VER_LINE"'/' $1
}
function sh_var_version()
{
  VER_LINE="version=$2 # $3"
  sed -i .applyVersion-bak 's/^version=.* # '$3'/'"$VER_LINE"'/' $1
}
function yaml_version()
{
  VER_LINE="version:\ $2 # $3"
  sed -i .applyVersion-bak 's/^\([\ \t]*\)version:.* # '$3'/'"\1$VER_LINE"'/' $1
}
function json_version()
{
  VER_LINE="\"version\":\ \"$2\","
  sed -i .applyVersion-bak 's/^\([\ \t]*\)"version":.*/\1'"$VER_LINE"'/' $1
}
function js_var_version()
{
  VER_LINE="var version\ =\ '$2'; \/\/ $3"
  sed -i .applyVersion-bak 's/^var version =.* \/\/ '$3'/'"$VER_LINE"'/' $1
}
function coffee_var_version()
{
  VER_LINE="version = '$2' # $3"
  sed -i .applyVersion-bak 's/^version =.* # '$3'/'"$2"'/' $1
}


