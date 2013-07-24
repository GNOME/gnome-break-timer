AM_CPPFLAGS = $(BREAK_TIMER_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_builddir)/common \
	-I $(top_builddir)/helper/util

noinst_LTLIBRARIES = \
	libc_x11_activity_monitor_backend.la \
	libactivity_monitor.la

libc_x11_activity_monitor_backend_la_SOURCES = \
	c_x11_activity_monitor_backend.c

libc_x11_activity_monitor_backend_la_LIBADD = $(BREAK_TIMER_LIBS)

libactivity_monitor_la_SOURCES = \
	ActivityMonitor.vala \
	X11ActivityMonitorBackend.vala

libactivity_monitor_la_VALAFLAGS = $(BREAK_TIMER_VALAFLAGS) \
	--pkg gdk-x11-3.0 \
	--library activity_monitor \
	--vapi activity_monitor.vapi \
	-H activity_monitor.h \
	$(top_builddir)/common/common.vapi \
	$(top_builddir)/helper/util/util.vapi

libactivity_monitor_la_LIBADD = $(BREAK_TIMER_LIBS) \
	libc_x11_activity_monitor_backend.la \
	$(top_builddir)/common/libcommon.la \
	$(top_builddir)/helper/util/libutil.la

libactivity_monitor_la_vala.stamp: \
	$(top_builddir)/common/libcommon_la_vala.stamp \
	$(top_builddir)/helper/util/libutil_la_vala.stamp

junk_files = \
	$(libactivity_monitor_la_SOURCES:.vala=.c) \
	libactivity_monitor_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	activity_monitor.vapi \
	activity_monitor.h
