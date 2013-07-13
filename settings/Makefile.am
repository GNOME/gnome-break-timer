AM_CPPFLAGS = $(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_builddir)/libgd \
	-I $(top_builddir)/common

SUBDIRS = 

bin_PROGRAMS = \
	brainbreak-settings

brainbreak_settings_SOURCES = \
	ApplicationPanel.vala \
	BreakManager.vala \
	BreakSettingsDialog.vala \
	BreakType.vala \
	MainWindow.vala \
	MicroBreakType.vala \
	RestBreakType.vala \
	TimeChooser.vala \
	TimerBreakType.vala \
	main.vala

brainbreak_settings_VALAFLAGS = $(BRAINBREAK_VALAFLAGS) \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg gee-1.0 \
	$(top_builddir)/libgd/gd-1.0.vapi \
	$(top_builddir)/common/common.vapi

brainbreak_settings_LDADD = $(BRAINBREAK_LIBS) \
	$(top_builddir)/libgd/libgd.la \
	$(top_builddir)/common/libcommon.la

brainbreak_settings_vala.stamp: \
	$(top_builddir)/common/libcommon_la_vala.stamp

junk_files = \
	$(brainbreak_settings_SOURCES:.vala=.c) \
	brainbreak_settings_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

