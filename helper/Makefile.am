include $(top_srcdir)/base.am
include $(top_srcdir)/helper/helper.am

SUBDIRS = \
	util \
	activity-monitor

bin_PROGRAMS = \
	gnome-break-timer-service


gnome_break_timer_service_SOURCES = main.vala $(HELPER_SOURCES)

gnome_break_timer_service_VALAFLAGS = $(HELPER_VALAFLAGS)

gnome_break_timer_service_CPPFLAGS = $(HELPER_CFLAGS)

gnome_break_timer_service_LDADD = $(HELPER_LIBS)

# Additional glib math library
gnome_break_timer_service_LDFLAGS = $(HELPER_LDFLAGS)

gnome_break_timer_service_vala.stamp: $(HELPER_DEPENDENCIES)


junk_files = \
	$(gnome_break_timer_service_SOURCES:.vala=.c) \
	gnome_break_timer_service_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

