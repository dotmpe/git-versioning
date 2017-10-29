#!/bin/bash

# Id: git-versioning/0.2.6-dev local-formats.sh

# Local formats: FIXME: for testing local extensions to lib/formats.sh

getVersion_local()
{
  case "$1" in

    *.gitconfig )
        get_unix_comment_id $1
      ;;

    * )
        return 1
      ;;

  esac
}

applyVersion_local()
{
  case "$1" in

    *.gitconfig )
        apply_commonUnixComment $1
      ;;

    * )
        return 1
      ;;
  esac
}
