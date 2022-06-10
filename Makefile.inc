%.dep: %/schema.sql
	sqldep $* <$< >$@
%.svg: %.dot
	dot -Tsvg $< >$@
.SECONDEXPANSION:
%.imp: $$(wildcard %/import*.wsf %/sync*.wsf)
	sqldep_import $(patsubst %.imp,%,$@) $^ >$@

#please define all.dep, all.imp
objects.dot: all.dep all.imp
	echo 'digraph {' >$@
	sqldep_to_dot <$< |sed '1d;$$d' >>$@
	cat all.imp >>$@
	echo '}' >>$@
schemata.dot: all.dep
	sqldep_to_schema_dot <$< >$@
