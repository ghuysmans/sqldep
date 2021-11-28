%.out: %.sql ../sqldep
	../sqldep <$< >$@
%.test: %.exp %.out
	diff $*.exp $*.out #FIXME?

all: $(patsubst %.sql,%.test,$(wildcard *.sql))
