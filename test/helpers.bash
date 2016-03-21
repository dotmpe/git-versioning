TMPF=/tmp/git-versioning-test.out

# FIXME: capture output in file for grep ops

output_to_file()
{
  [ -n "$1" ] && TMPF=$1
  total=${#lines[*]}
  rm $TMPF
  touch $TMPF
  for (( i=0; i<=$(( $total -1 )); i++ ))
  do 
    echo ${lines[$i]} >> $TMPF
  done
}

read_lines()
{
  test -e $TMPF
  cat $TPMF | grep -v '^#' | grep -v '^[\s]*$' \
    | while read line
  do
    #[ -n "$(echo "$line")" ] || continue
    echo "$line"
  done
}

output_lists_versioned_files()
{
  cat $TPMF | grep -v '^#' | grep -v '^[\s]*$' \
    | grep '^Version.*match\ in' | while read vl
  do 
    echo checking $vl
#fn=$(echo $vl | sed 's/^.*\([^\ ]*\)$/\1/g')
#    grep $fn .versioned-files.list >> /dev/null
#    echo check $fn
  done
  rm $TMPF
}

# Id: git-versioning/0.0.28 test/helpers.bash

