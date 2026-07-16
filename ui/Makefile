ERLC_OPTS =

EBIND = ebin
UI_BIN = bencherlui/ebin/bencherlui.app

ERLF = $(wildcard *.erl)
BEAMF = $(patsubst %.erl,$(EBIND)/%.beam,$(ERLF))

# ChicagoBoss 0.9, built with rebar3, and rebar 2, which builds ChicagoBoss
# applications. The files in patches/ make them work with current Erlang/OTP.
CB_URL = https://github.com/ChicagoBoss/ChicagoBoss.git
CB_COMMIT = c7b9119b090cf5f4439e8b2b034a4541e746ab0c
CB_STAMP = ChicagoBoss/.built-$(CB_COMMIT)
CB_PATCHED_DEPS = boss_db ddb epgsql erlando erlydtl gen_smtp iso8601 \
	mochiweb simple_bridge
REBAR2_URL = https://github.com/rebar/rebar.git
REBAR2_COMMIT = b6d309417c502ca243f810e5313bea36951ef038

# Some dependencies are fetched from git:// URLs, which GitHub no longer
# serves.
GIT_HTTPS = GIT_CONFIG_COUNT=1 \
	GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf \
	GIT_CONFIG_VALUE_0=git://github.com/

.PHONY: clean ui

ui: $(UI_BIN) $(BEAMF)
	cd bencherlui ; \
	./rebar compile

$(EBIND)/%.beam: %.erl
	erlc $(ERLC_OPTS) -o$(EBIND) $<

$(BEAMF): | $(EBIND)

$(EBIND):
	mkdir -p $(EBIND)

$(CB_STAMP):
	rm -rf ChicagoBoss
	git clone $(CB_URL) ChicagoBoss
	cd ChicagoBoss && git checkout -q $(CB_COMMIT) && \
		patch -p1 < ../patches/ChicagoBoss.patch
	cp ChicagoBoss.rebar.lock ChicagoBoss/rebar.lock
	cd ChicagoBoss && $(GIT_HTTPS) rebar3 get-deps
	for d in $(CB_PATCHED_DEPS); do \
		patch -d ChicagoBoss/_build/default/lib/$$d -p1 \
			< patches/$$d.patch || exit 1; \
	done
	cd ChicagoBoss && $(GIT_HTTPS) rebar3 compile
	# ChicagoBoss looks for its modules in ebin/ and its dependencies in
	# deps/, where rebar 2 put them.
	cd ChicagoBoss && mkdir -p deps && \
		for d in _build/default/lib/*; do \
			[ $$(basename $$d) = boss ] || ln -sfn ../$$d deps/; \
		done && \
		ln -sfn _build/default/lib/boss/ebin ebin
	touch $@

# The rebar 2 library modules are put first in the code path, as the rebar
# library of rebar3 may be installed with Erlang and has modules of the
# same names.
bencherlui/rebar:
	rm -rf rebar2
	git clone $(REBAR2_URL) rebar2
	cd rebar2 && git checkout -q $(REBAR2_COMMIT) && \
		ERL_FLAGS="-pa ebin" ./bootstrap
	cp rebar2/rebar $@

$(UI_BIN): $(CB_STAMP) bencherlui/rebar
	rm -rf bencherlui/boss.config ; \
	cp bencherlui/boss.config.in bencherlui/boss.config ; \
	sed -i -e "s@BENCHERL_UI_PATH@`pwd`@g" bencherlui/boss.config ; \
	NUMBER=`awk -vmin=0 -vmax=1000000000 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'` ; \
	ALPHA_NUMBERIC_PATH=$$(echo `pwd` | sed 's/[^a-zA-Z0-9]//g') ; \
	NODE_NAME="$$ALPHA_NUMBERIC_PATH""$$NUMBER" ; \
	sed -i -e 's@VM_SHORT_NAME@'"$$NODE_NAME"'@g' bencherlui/boss.config ; \
	sed -i -e 's@VM_NAME@'"$$NODE_NAME"'@g' bencherlui/boss.config ; \
	cd bencherlui ; \
	./rebar compile

clean:
	$(RM) -rf $(EBIND)
	if [ -x bencherlui/rebar ]; then \
		cd bencherlui && ./rebar clean; \
	fi
	rm -rf bencherlui/boss.config
