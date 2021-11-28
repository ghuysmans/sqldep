%.out: %.sql ../sqldep
	../sqldep <$< >$@
%.test: %.exp %.out
	diff $*.exp $*.out

test: $(patsubst %.sql,%.test,$(wildcard *.sql))
