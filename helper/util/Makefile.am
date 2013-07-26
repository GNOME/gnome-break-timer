include $(top_srcdir)/base.am

noinst_LTLIBRARIES = \
	libutil.la

libutil_la_SOURCES = \
	Countdown.vala \
	PausableTimeout.vala \
	SimpleFocusManager.vala \
	StatefulTimer.vala \
	Util.vala

libutil_la_VALAFLAGS = $(BASE_VALAFLAGS) \
	--library util \
	--vapi util.vapi \
	-H util.h

libutil_la_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS)

libutil_la_LIBADD = $(BASE_LIBS)

junk_files = \
	$(libutil_la_SOURCES:.vala=.c) \
	libutil_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	util.vapi \
	util.h
