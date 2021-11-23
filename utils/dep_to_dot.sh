#!/bin/sh
echo 'digraph {'
sed -Ee 's/^([A-Za-z0-9_.]+): (.*)/\1 -> {\2}/' -e 's/\./__/g'
echo '}'
