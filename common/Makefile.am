include $(top_srcdir)/base.am
include $(top_srcdir)/common/common.am

noinst_LTLIBRARIES = \
	libcommon.la


libcommon_la_SOURCES = $(COMMON_SOURCES)

libcommon_la_VALAFLAGS = $(COMMON_VALAFLAGS) \
	--library common \
	--vapi common.vapi \
	-H common.h

libcommon_la_CPPFLAGS = $(COMMON_CFLAGS)

libcommon_la_LIBADD = $(COMMON_LIBS)


junk_files = \
	$(libcommon_la_SOURCES:.vala=.c) \
	libcommon_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	common.vapi \
	common.h

