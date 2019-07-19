# # #
# Updates the embedded scripts in configure-utils.mk
# embed-src updates or adds any awk scripts in the src/ directory:
# embedding them in configure-utils.mk.
# 
# embed-awk can be used to embed an awk script into ay Makefile
# See embed-src for a sample invocation

AWK = awk --posix

embed-src:
	$(eval sources = $(shell find src/ -name '*.awk' ))
	@for src in ${sources}; do \
		$(MAKE) -s -f update-embeds.mk embed-awk -- --target=configure-utils.mk --embed-file="$$src"; \
	done;

embed-awk: EMBED_FILE = ${--embed-file}
embed-awk: OUTFILE = ${--target}
embed-awk: TMP_TARGET := $(shell echo /tmp/f-$$(od -An -N4 -tx /dev/urandom| tr -d ' '))
embed-awk: TMP_SOURCE := $(shell echo /tmp/f-$$(od -An -N4 -tx /dev/urandom| tr -d ' '))
embed-awk: export DEFINE_NAME = $(shell basename ${EMBED_FILE})
embed-awk:
	$(info Embedding ${EMBED_FILE})
	cat ${EMBED_FILE} | $(AWK) -f src/minify.awk | $(AWK) -f src/recipe-escape.awk > ${TMP_SOURCE}
	cp ${OUTFILE} ${TMP_TARGET}	
	SOURCE_FILE="${TMP_SOURCE}" $(AWK) -f src/embed-script-in-make.awk <${TMP_TARGET} >${OUTFILE}
	rm ${TMP_TARGET} ${TMP_SOURCE}
