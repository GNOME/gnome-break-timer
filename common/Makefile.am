AM_CPPFLAGS = $(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER)

noinst_LTLIBRARIES = \
	libcommon.la

libcommon_la_SOURCES = \
	NaturalTime.vala \
	SessionStatus.vala

libcommon_la_LIBADD = $(BRAINBREAK_LIBS)

libcommon_la_VALAFLAGS = $(BRAINBREAK_VALAFLAGS) \
	--pkg gio-2.0 \
	--library common \
	--vapi common.vapi \
	-H common.h

junk_files = \
	$(libcommon_la_SOURCES:.vala=.c) \
	libcommon_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	common.vapi \
	common.h

