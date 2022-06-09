%.dep: %/schema.sql
	sqldep $* <$< >$@
%.svg: %.dot
	dot -Tsvg $< >$@
.SECONDEXPANSION:
%.imp: $$(wildcard %/import*.wsf %/sync*.wsf)
	sqldep_import $(patsubst %.imp,%,$@) /dev/null $^ >$@

#please define all.dep
objects.dot: all.dep
	sqldep_to_dot <$< >$@
schemata.dot: all.dep
	sqldep_to_schema_dot <$< >$@
