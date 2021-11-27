#!/bin/sh
echo 'digraph {'
(
	if [ -z "$1" ]; then
		cat
	else
		sed -E "s/([A-Za-z0-9_.]+)/$1.\1/g" |
		sed -E "s/$1\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)/\1.\2/g" |
		sed -E 's/^[^.]+\.(TABLE|VIEW)/\1/'
	fi
) |
sed -Ee 's/^TABLE ([^:]+)/\1 [shape=cylinder]\n\1/' \
    -e 's/^VIEW ([^:]+)/\1 [shape=house]\n\1/' |
sed -Ee 's/^([A-Za-z0-9_.]+): (.*)/\1 -> {\2}/' -e 's/\./__/g'
echo '}'
