#!/bin/sh
#please put table enumerations on the same line (e.g. FROM t, u)
tr -d '\r' |
sed -E 's/(^|\s)(FROM|JOIN)\s+/\n\2 /g' |
sed -nEe 's/CREATE VIEW ([A-Za-z0-9_.]+) AS/%!\1:/p' \
    -e 's/.*(FROM|JOIN)\s+([A-Za-z0-9_.]+(,\s+[A-Za-z0-9_.]+)*)/%\2\n/p' |
sed -ne 's/^%\(.*\)/\1/p' |
tr '\n!' ' \n' |
tail -n +2
echo
