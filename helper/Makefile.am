include $(top_srcdir)/base.am
include $(top_srcdir)/helper/helper.am

SUBDIRS = \
	util \
	activity-monitor

noinst_LTLIBRARIES = \
	libgnome_break_timer_service.la

libgnome_break_timer_service_la_SOURCES = $(HELPER_SOURCES)
libgnome_break_timer_service_la_VALAFLAGS = $(HELPER_VALAFLAGS) \
	--library gnome_break_timer_service \
	--vapi gnome_break_timer_service.vapi \
	-H gnome_break_timer_service.h
libgnome_break_timer_service_la_CPPFLAGS = $(HELPER_CFLAGS)
libgnome_break_timer_service_la_LIBADD = $(HELPER_LIBS)
libgnome_break_timer_service_la_vala.stamp: $(HELPER_DEPENDENCIES)


bin_PROGRAMS = \
	gnome-break-timer-service

gnome_break_timer_service_SOURCES = main.vala
gnome_break_timer_service_VALAFLAGS = $(HELPER_VALAFLAGS) \
	--pkg gnome_break_timer_service
gnome_break_timer_service_CPPFLAGS = $(HELPER_CFLAGS)
gnome_break_timer_service_LDADD = $(HELPER_LIBS) \
	$(top_builddir)/helper/libgnome_break_timer_service.la
gnome_break_timer_service_vala.stamp: \
	$(top_builddir)/helper/libgnome_break_timer_service.la


junk_files = \
	$(gnome_break_timer_service_SOURCES:.vala=.c) \
	gnome_break_timer_service_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

