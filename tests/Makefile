%.out: %.sql ../sqldep
	../sqldep <$< >$@
%.test: %.exp %.out
	diff $*.exp $*.out

all: $(patsubst %.sql,%.test,$(wildcard *.sql))
