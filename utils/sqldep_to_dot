#!/bin/sh
echo 'digraph {'
sed -Ee 's/^TABLE ([^:]+)/\1 [shape=cylinder]\n\1/' \
    -e 's/^VIEW ([^:]+)/\1 [shape=house]\n\1/' |
sed -Ee 's/^([A-Za-z0-9_]+)\.([A-Za-z0-9_]+) \[/\1__\2 [label="\1.\2", /' -e '/:/s/\./__/g' |
sed -E 's/^([^:]+): (.*)/\1 -> {\2}/'
echo '}'
