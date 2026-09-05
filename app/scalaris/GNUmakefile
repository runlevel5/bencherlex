# bencherl builds the applications that a benchmark uses with "make app".
# Scalaris has to be configured first. make reads this file before the
# Makefile that configure generates: it configures Scalaris when needed,
# and gives every other target to that Makefile.

# The output directories of the Emakefile have to exist; git does not keep
# the empty ones.
app: Makefile
	mkdir -p $$(sed -n 's/.*{outdir, *"\([^"]*\)"}.*/\1/p' Emakefile.in)
	$(MAKE) -f Makefile nifs compile

Makefile: Makefile.in configure
	./configure

clean:
	if [ -f Makefile ]; then $(MAKE) -f Makefile clean; fi

GNUmakefile Makefile.in configure: ;

.DEFAULT: Makefile
	$(MAKE) -f Makefile $@

.PHONY: app clean
