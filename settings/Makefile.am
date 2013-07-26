include $(top_srcdir)/base.am

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

gnome_break_timer_VALAFLAGS = $(BASE_VALAFLAGS) \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg gee-1.0 \
	$(top_srcdir)/config.vapi \
	$(top_builddir)/common/common.vapi \
	$(top_builddir)/libgd/gd-1.0.vapi

gnome_break_timer_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS)

gnome_break_timer_LDADD = $(BASE_LIBS) \
	$(top_builddir)/libgd/libgd.la \
	$(top_builddir)/common/libcommon.la

gnome_break_timer_vala.stamp: \
	$(top_builddir)/common/libcommon_la_vala.stamp

junk_files = \
	$(gnome_break_timer_SOURCES:.vala=.c) \
	gnome_break_timer_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

