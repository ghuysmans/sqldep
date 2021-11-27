#!/bin/sh
#please put table enumerations on the same line (e.g. FROM t, u)
tr -d '\r' |
sed -E 's/(^|\s)(FROM|JOIN|REFERENCES)\s+/\n\2 /g' |
sed -nEe 's/CREATE (VIEW)\s+([A-Za-z0-9_.]+)\s+AS/%!\1 \2:/p' \
    -e 's/CREATE (TABLE)\s+([A-Za-z0-9_.]+)\s*\(/%!\1 \2:/p' \
    -e 's/.*(FROM|JOIN|REFERENCES)\s+([A-Za-z0-9_.]+(,\s+[A-Za-z0-9_.]+)*)/%\2\n/p' |
sed -ne 's/^%\(.*\)/\1/p' |
tr '\n!' ' \n' |
tail -n +2
echo
