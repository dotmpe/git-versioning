#!/bin/bash

# Id: git-versioning/0.2.4 lib/formats.sh

# Markdown
MD_VER_TOKEN='\([Vv]\)ersion:'
# Main version line has no further qualifier
function apply_md_field_main_version()
{
  VER_LINE="\1ersion:\ $VER_STR"
  sed_rewrite_tag 's/^'$MD_VER_TOKEN'.*/'"$VER_LINE"'/' $1
}
function get_md_field_main_version()
{
  grep '^'$MD_VER_TOKEN'.*' $1 | awk '{print $2}'
}
# [comment]: #
# Common Id line adapted to above variant of MD comments
function apply_md_comment_id()
{
  ID_LINE="[comment]: # Id: $APP_ID\/$VER_STR "$(echo $1 | sed 's/\//\\\//g')
  sed_rewrite_tag 's/^[comment]:\ #\ Id: '$APP_ID'.*/'"$ID_LINE"'/' $1
}
function get_md_comment_id()
{
  grep '^.comment.:\ #\ Id:\ '$APP_ID $1 | \
    sed 's/^.comment.: # Id: [^\/]*\/\([^\ ]*\).*$/\1/'
}



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
# JS:Coffee-Script
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

getVersion_lib()
{
  case "$1" in

    *.md )

        if [ "$1" = "$V_MAIN_DOC" -o "$1" = "./$V_MAIN_DOC" ]
        then

          get_md_field_main_version $1 | while read STR
          do echo "Md Field Version (Main): $STR"; done

        fi

        get_md_comment_id $1 | while read STR
        do echo "Md Comment Id: $STR"; done
      ;;

    *.rst )

        if [ "$1" = "$V_MAIN_DOC" -o "$1" = "./$V_MAIN_DOC" ]
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
        return 1
      ;;

  esac
}

applyVersion_lib()
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

    *.mk | */Makefile | Makefile )
        apply_commonUnixComment $doc
        apply_mk_var_version $doc
      ;;

    *.sh | *.bash | configure | */configure | *.bats )
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

    *.coffee | *.go )
        apply_commonUnixComment $doc
        apply_coffee_var_version $doc
      ;;

    *.py )
        apply_commonUnixComment $doc
        version_quotes=1 apply_var_version $doc
        version_quotes=1 version_varname=__version__ apply_var_version $doc
      ;;

    *.properties )
        apply_commonUnixComment $doc
        apply_properties_version $doc
      ;;

    *build.xml )
        apply_xml_comment_id $doc
        apply_ant_var_version $doc
      ;;

    *.xml )
        apply_xml_comment_id $doc
      ;;

    *.pde | *.ino | *.c | *.cpp | *.h )
        apply_commonUnixComment $doc
        apply_clike_line_comment_id $doc
      ;;

    *.pug | *.styl | *.pde | *.ino | *.c | *.cpp | *.h | *.java | *.groovy )
        apply_clike_line_comment_id $doc
      ;;

    Dockerfile | */Dockerfile )
        apply_commonUnixComment $doc
      ;;

    * )
        # NOTE: git-versioning could just replace if tag is detailed enough (ie.
        # snapshot), or if forced to (or if there's no need to watch other embedded versions).
        # But it does not support this mode.
        return 1
      ;;

  esac

  echo "$doc @$VER_STR"

  unset doc
}
