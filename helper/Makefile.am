AM_CPPFLAGS = \
	$(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-I $(top_srcdir)/common \
	-I activity-monitor \
	-I util

SUBDIRS = \
	activity-monitor \
	util

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
	BreakFocusManager.vala \
	main.vala \
	ScreenOverlay.vala \
	UIManager.vala

brainbreak_VALAFLAGS = \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gee-1.0 \
	--pkg libnotify \
	$(top_srcdir)/common/natural_time.vapi \
	activity-monitor/activity_monitor.vapi \
	util/util.vapi

brainbreak_LDADD = \
	$(BRAINBREAK_LIBS) \
	$(top_srcdir)/common/libnatural_time.la \
	activity-monitor/libactivity_monitor.la \
	util/libutil.la

brainbreak_LDFLAGS = -lm

brainbreak_vala.stamp: \
	$(top_srcdir)/common/libnatural_time_la_vala.stamp \
	activity-monitor/libactivity_monitor_la_vala.stamp \
	util/libutil_la_vala.stamp

junk_files = \
	$(brainbreak_SOURCES:.vala=.c) \
	brainbreak_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

