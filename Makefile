PREFIX ?= $(HOME)/.local/bin

all:
install: sqldep utils/sqldep_to_dot utils/sqldep_to_schema_dot
	cp $^ $(PREFIX)
	sed -i 's#\./##' $(PREFIX)/sqldep_to_schema_dot
