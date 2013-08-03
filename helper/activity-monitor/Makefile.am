include $(top_srcdir)/base.am
include $(top_srcdir)/helper/activity-monitor/activity-monitor.am

noinst_LTLIBRARIES = \
	libactivity_monitor.la

libactivity_monitor_la_SOURCES = $(HELPER_ACTIVITY_MONITOR_SOURCES)

libactivity_monitor_la_VALAFLAGS = $(HELPER_ACTIVITY_MONITOR_VALAFLAGS) \
	--library activity_monitor \
	--vapi activity_monitor.vapi \
	-H activity_monitor.h

libactivity_monitor_la_CPPFLAGS = $(HELPER_ACTIVITY_MONITOR_CFLAGS)

libactivity_monitor_la_LIBADD = $(HELPER_ACTIVITY_MONITOR_LIBS)

libactivity_monitor_la_vala.stamp: $(HELPER_ACTIVITY_MONITOR_DEPENDENCIES)


junk_files = \
	$(HELPER_ACTIVITY_MONITOR_VALASOURCES:.vala=.c) \
	libactivity_monitor_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	activity_monitor.vapi \
	activity_monitor.h
