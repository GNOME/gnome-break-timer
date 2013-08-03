include $(top_srcdir)/base.am
include $(top_srcdir)/settings/settings.am

SUBDIRS = 

BUILT_SOURCES = resources.c

resources.c: $(top_srcdir)/data/gnome-break-timer.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data/ $(top_srcdir)/data/gnome-break-timer.gresource.xml)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data/ --generate-source $<

bin_PROGRAMS = \
	gnome-break-timer


gnome_break_timer_SOURCES = \
	BreakManager.vala \
	BreakSettingsDialog.vala \
	BreakType.vala \
	MainWindow.vala \
	MicroBreakType.vala \
	RestBreakType.vala \
	TimeChooser.vala \
	TimerBreakType.vala \
	WindowHeaderBar.vala \
	main.vala \
	$(BUILT_SOURCES)

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

