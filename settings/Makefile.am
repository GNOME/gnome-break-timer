AM_CPPFLAGS = $(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_srcdir)/common

SUBDIRS = 

bin_PROGRAMS = \
	brainbreak-settings

brainbreak_settings_SOURCES = \
	ApplicationPanel.vala \
	BreakPanel.vala \
	BreakType.vala \
	main.vala \
	MicroBreakType.vala \
	Panel.vala \
	QuietMode.vala \
	QuietModePanel.vala \
	RestBreakType.vala \
	SettingsDialog.vala \
	TimeChooser.vala \
	TimerBreakPanel.vala \
	TimerBreakType.vala

brainbreak_settings_VALAFLAGS = \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg gee-1.0 \
	$(top_srcdir)/common/common.vapi

brainbreak_settings_LDADD = \
	$(BRAINBREAK_LIBS) \
	$(top_srcdir)/common/libcommon.la

brainbreak_settings_vala.stamp: \
	$(top_srcdir)/common/libcommon_la_vala.stamp

junk_files = \
	$(brainbreak_settings_SOURCES:.vala=.c) \
	brainbreak_settings_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

