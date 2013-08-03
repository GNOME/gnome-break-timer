include $(top_srcdir)/base.am
include $(top_srcdir)/settings/settings.am

SUBDIRS = 

bin_PROGRAMS = \
	gnome-break-timer


gnome_break_timer_SOURCES = main.vala $(SETTINGS_SOURCES)

gnome_break_timer_VALAFLAGS = $(SETTINGS_VALAFLAGS)

gnome_break_timer_CPPFLAGS = $(SETTINGS_CFLAGS)

gnome_break_timer_LDADD = $(SETTINGS_LIBS)

gnome_break_timer_vala.stamp: $(SETTINGS_DEPENDENCIES)


junk_files = \
	$(gnome_break_timer_SOURCES:.vala=.c) \
	gnome_break_timer_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

