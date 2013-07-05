SUBDIRS = \
	util \
	activity-monitor

AM_CPPFLAGS = $(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_srcdir)/common \
	-I $(top_srcdir)/helper/activity-monitor \
	-I $(top_srcdir)/helper/util

bin_PROGRAMS = \
	brainbreak

brainbreak_SOURCES = \
	break/BreakController.vala \
	break/BreakType.vala \
	break/BreakView.vala \
	break/TimerBreakController.vala \
	break/TimerBreakStatusWidget.vala \
	break/TimerBreakView.vala \
	microbreak/MicroBreakController.vala \
	microbreak/MicroBreakType.vala \
	microbreak/MicroBreakView.vala \
	restbreak/RestBreakController.vala \
	restbreak/RestBreakType.vala \
	restbreak/RestBreakView.vala \
	BreakManager.vala \
	main.vala \
	ScreenOverlay.vala \
	UIManager.vala

brainbreak_VALAFLAGS = $(BRAINBREAK_VALAFLAGS) \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg libnotify \
	$(top_srcdir)/common/common.vapi \
	$(top_srcdir)/helper/activity-monitor/activity_monitor.vapi \
	$(top_srcdir)/helper/util/util.vapi

brainbreak_LDADD = $(BRAINBREAK_LIBS) \
	$(top_srcdir)/common/libcommon.la \
	$(top_srcdir)/helper/activity-monitor/libactivity_monitor.la \
	$(top_srcdir)/helper/util/libutil.la

brainbreak_LDFLAGS = -lm

brainbreak_vala.stamp: \
	$(top_srcdir)/common/libcommon_la_vala.stamp \
	$(top_srcdir)/helper/activity-monitor/libactivity_monitor_la_vala.stamp \
	$(top_srcdir)/helper/util/libutil_la_vala.stamp

junk_files = \
	$(brainbreak_SOURCES:.vala=.c) \
	brainbreak_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

