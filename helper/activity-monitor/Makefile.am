AM_CPPFLAGS = $(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_srcdir)/common \
	-I $(top_srcdir)/helper/util

noinst_LTLIBRARIES = \
	libc_x11_activity_monitor_backend.la \
	libactivity_monitor.la

libc_x11_activity_monitor_backend_la_SOURCES = \
	c_x11_activity_monitor_backend.c

libc_x11_activity_monitor_backend_la_LIBADD = $(BRAINBREAK_LIBS)

libactivity_monitor_la_SOURCES = \
	ActivityMonitor.vala \
	X11ActivityMonitorBackend.vala

libactivity_monitor_la_VALAFLAGS = $(BRAINBREAK_VALAFLAGS) \
	--pkg gdk-x11-3.0 \
	--library activity_monitor \
	--vapi activity_monitor.vapi \
	-H activity_monitor.h \
	$(top_srcdir)/common/common.vapi \
	$(top_srcdir)/helper/util/util.vapi

libactivity_monitor_la_LIBADD = $(BRAINBREAK_LIBS) \
	libc_x11_activity_monitor_backend.la \
	$(top_srcdir)/common/libcommon.la \
	$(top_srcdir)/helper/util/libutil.la

libactivity_monitor_la_vala.stamp: \
	$(top_srcdir)/common/libcommon_la_vala.stamp \
	$(top_srcdir)/helper/util/libutil_la_vala.stamp

junk_files = \
	$(libactivity_monitor_la_SOURCES:.vala=.c) \
	libactivity_monitor_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	activity_monitor.vapi \
	activity_monitor.h
