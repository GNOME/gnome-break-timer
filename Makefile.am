SUBDIRS = \
	data \
	po \
	common \
	settings \
	helper \
	tests

ACLOCAL_AMFLAGS = -I m4

INTLTOOL_FILES = intltool-extract.in \
                 intltool-merge.in \
                 intltool-update.in

BrainBreakdocdir = ${prefix}/doc/BrainBreak
BrainBreakdoc_DATA = \
	README \
	COPYING \
	AUTHORS

EXTRA_DIST = \
	autogen.sh \
	config.vapi \
	$(BrainBreakdoc_DATA) \
	intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

DISTCLEANFILES = \
	intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache
