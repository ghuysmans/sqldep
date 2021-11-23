#!/bin/sh
#please put each FROM/JOIN on a separate line
tr -d '\r' |
sed -nEe 's/CREATE VIEW ([A-Za-z0-9_.]+) AS/%!\1:/p' \
    -e 's/.*(FROM|JOIN)\s+([A-Za-z0-9_.]+(,\s+[A-Za-z0-9_.]+)*)/%\2\n/p' |
sed -ne 's/^%\(.*\)/\1/p' |
tr '\n!' ' \n' |
tail -n +2
echo
