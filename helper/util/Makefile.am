include $(top_srcdir)/base.am
include $(top_srcdir)/helper/util/util.am

noinst_LTLIBRARIES = \
	libutil.la


libutil_la_SOURCES = $(HELPER_UTIL_SOURCES)

libutil_la_VALAFLAGS = $(HELPER_UTIL_VALAFLAGS) \
	--library util \
	--vapi util.vapi \
	-H util.h

libutil_la_CPPFLAGS = $(HELPER_UTIL_CFLAGS)

libutil_la_LIBADD = $(HELPER_UTIL_LIBS)


junk_files = \
	$(libutil_la_SOURCES:.vala=.c) \
	libutil_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	util.vapi \
	util.h
