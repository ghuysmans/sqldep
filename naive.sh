#!/bin/sh
#please put each FROM/JOIN on a separate line
#this won't work on files with DOS line endings
sed -nEe 's/CREATE VIEW ([A-Za-z0-9_.]+) AS/%!\1:/p' \
    -e 's/.*(FROM|JOIN) ([A-Za-z0-9_.]+(,\s*[A-Za-z0-9_.]+)*)/%\2\n/p' |
sed -ne 's/^%\(.*\)/\1/p' |
tr '\n!' ' \n' |
tail -n +2
echo