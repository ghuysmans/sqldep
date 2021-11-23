#!/bin/sh
echo 'digraph {'
sed -E 's/^([A-Za-z0-9_.]+): (.*)/\1 -> {\2}/'
echo '}'
