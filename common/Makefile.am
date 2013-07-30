include $(top_srcdir)/base.am

noinst_LTLIBRARIES = \
	libcommon.la

libcommon_la_SOURCES = \
	IBreakHelper.vala \
	ISessionStatus.vala \
	NaturalTime.vala

libcommon_la_VALAFLAGS = $(BASE_VALAFLAGS) \
	--pkg gio-2.0 \
	--library common \
	--vapi common.vapi \
	-H common.h

libcommon_la_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS)

libcommon_la_LIBADD = $(BASE_LIBS)

junk_files = \
	$(libcommon_la_SOURCES:.vala=.c) \
	libcommon_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	common.vapi \
	common.h

