include $(top_srcdir)/base.am

noinst_LTLIBRARIES = \
	libc_x11_activity_monitor_backend.la \
	libactivity_monitor.la

libc_x11_activity_monitor_backend_la_SOURCES = \
	c_x11_activity_monitor_backend.c

libc_x11_activity_monitor_backend_la_CPPFLAGS = $(AM_CPPFLAGS) \
	$(ACTIVITY_MONITOR_BACKEND_CFLAGS)

libc_x11_activity_monitor_backend_la_LIBADD = \
	$(ACTIVITY_MONITOR_BACKEND_LIBS)

libactivity_monitor_la_SOURCES = \
	ActivityMonitor.vala \
	X11ActivityMonitorBackend.vala

libactivity_monitor_la_VALAFLAGS = $(BASE_VALAFLAGS) \
	--pkg gdk-x11-3.0 \
	--library activity_monitor \
	--vapi activity_monitor.vapi \
	-H activity_monitor.h \
	$(top_builddir)/common/common.vapi \
	$(top_builddir)/helper/util/util.vapi

libactivity_monitor_la_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS) \
	$(ACTIVITY_MONITOR_CFLAGS)

libactivity_monitor_la_LIBADD = $(BASE_LIBS) \
	$(ACTIVITY_MONITOR_LIBS) \
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
