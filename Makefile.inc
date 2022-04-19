%.dep: %/schema.sql
	sqldep $* <$< >$@
%.svg: %.dot
	dot -Tsvg $< >$@

#please define all.dep
objects.dot: all.dep
	sqldep_to_dot <$< >$@
schemata.dot: all.dep
	sqldep_to_schema_dot <$< >$@
