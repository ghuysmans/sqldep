dep: objects.svg schemata.svg
all.dep: print.dep school.dep
	cat $^ >$@
check: all.dep
	sqldep_check $^

include ../Makefile.inc
