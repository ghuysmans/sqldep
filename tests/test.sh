#!/bin/sh
set -e

if [ -z "$1" ]; then
  echo usage: test.sh schema.sql
  exit 1
fi
NAME=`basename "$1"`

dune exec ../bin/main.exe <$1 >$NAME.dep.out
diff $NAME.dep.exp $NAME.dep.out

sed 's/: .*//' $NAME.dep.out >$NAME.lst.out
grep "CREATE VIEW" $1 |sed -e 's/CREATE VIEW //' -e 's/ AS//' >$NAME.lst.exp
diff $NAME.lst.exp $NAME.lst.out
