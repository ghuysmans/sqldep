#!/bin/sh
sed -Ee 's/^VIEW/TABLE/' -e "s/([A-Za-z0-9_]+)\.[A-Za-z0-9_]+/\1/g" |
./dep_to_dot.sh |
sed '1s/^/strict /'
