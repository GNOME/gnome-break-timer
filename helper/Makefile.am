include $(top_srcdir)/base.am

SUBDIRS = \
	util \
	activity-monitor

bin_PROGRAMS = \
	gnome-break-timer-service

gnome_break_timer_service_SOURCES = \
	break/BreakController.vala \
	break/BreakType.vala \
	break/BreakView.vala \
	break/TimerBreakController.vala \
	break/TimerBreakType.vala \
	break/TimerBreakStatusWidget.vala \
	break/TimerBreakView.vala \
	microbreak/MicroBreakController.vala \
	microbreak/MicroBreakType.vala \
	microbreak/MicroBreakView.vala \
	restbreak/RestBreakController.vala \
	restbreak/RestBreakType.vala \
	restbreak/RestBreakView.vala \
	BreakManager.vala \
	ScreenOverlay.vala \
	SessionStatus.vala \
	UIManager.vala \
	main.vala

gnome_break_timer_service_VALAFLAGS = $(BASE_VALAFLAGS) \
	--pkg gtk+-3.0 \
	--pkg gio-2.0 \
	--pkg gio-unix-2.0 \
	--pkg gee-1.0 \
	--pkg libcanberra \
	--pkg libcanberra-gtk \
	--pkg libnotify \
	$(top_srcdir)/config.vapi \
	$(top_builddir)/common/common.vapi \
	$(top_builddir)/helper/activity-monitor/activity_monitor.vapi \
	$(top_builddir)/helper/util/util.vapi

gnome_break_timer_service_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS) \
	$(HELPER_CFLAGS)

gnome_break_timer_service_LDADD = $(BASE_LIBS) \
	$(HELPER_LIBS) \
	$(top_builddir)/common/libcommon.la \
	$(top_builddir)/helper/activity-monitor/libactivity_monitor.la \
	$(top_builddir)/helper/util/libutil.la

# Additional glib math library
gnome_break_timer_service_LDFLAGS = -lm

gnome_break_timer_service_vala.stamp: \
	$(top_builddir)/common/libcommon_la_vala.stamp \
	$(top_builddir)/helper/activity-monitor/libactivity_monitor_la_vala.stamp \
	$(top_builddir)/helper/util/libutil_la_vala.stamp

junk_files = \
	$(gnome_break_timer_service_SOURCES:.vala=.c) \
	gnome_break_timer_service_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)

