PREFIX ?= $(HOME)/.local/bin

all:
install: sqldep utils/dep_to_dot.sh utils/dep_to_schema_dot.sh
	cp sqldep $(PREFIX)
	cp utils/dep_to_dot.sh $(PREFIX)/sqldep_to_dot
	cp utils/dep_to_schema_dot.sh $(PREFIX)/sqldep_to_schema_dot
	sed -i 's#\./dep_to_dot\.sh#sqldep_to_dot#' $(PREFIX)/sqldep_to_schema_dot
