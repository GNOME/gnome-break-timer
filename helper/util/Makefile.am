AM_CPPFLAGS = \
	$(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER)

noinst_LTLIBRARIES = \
	libutil.la

libutil_la_SOURCES = \
	Countdown.vala \
	PausableTimeout.vala \
	SimpleFocusManager.vala

libutil_la_LIBADD = \
	$(BRAINBREAK_LIBS)

libutil_la_VALAFLAGS = \
	--library util \
	--vapi util.vapi \
	-H util.h

junk_files = \
	$(libutil_la_SOURCES:.vala=.c) \
	libutil_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	util.vapi \
	util.h

