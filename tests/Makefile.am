include $(top_srcdir)/base.am
include $(top_srcdir)/helper/helper.am
include $(top_srcdir)/settings/settings.am

junk_files =

AM_VALAFLAGS = $(HELPER_VALAFLAGS) \
	--pkg posix \
	--pkg gnome_break_timer_service
AM_CPPFLAGS = $(HELPER_CFLAGS)
AM_LDFLAGS = $(HELPER_LDFLAGS)
TEST_LIBS = $(HELPER_LIBS) \
	$(top_builddir)/helper/libgnome_break_timer_service.la

test_%.stamp: $(HELPER_DEPENDENCIES) \
	$(top_builddir)/helper/libgnome_break_timer_service.la


# Unit tests for "libcommon" convenience library

TEST_PROGS += test-common

test_common_SOURCES = \
	tests.vala \
	common/common_runner.vala \
	common/test_NaturalTime.vala

test_common_LDADD = $(TEST_LIBS)

junk_files += \
	$(test_common_SOURCES:.vala=.c) \
	test_common_vala.stamp


# Unit tests for "activity-monitor" convenience library

TEST_PROGS += test-activity-monitor

test_activity_monitor_SOURCES = \
	tests.vala \
	activity-monitor/activity-monitor_runner.vala \
	activity-monitor/test_ActivityMonitor.vala

test_activity_monitor_LDADD = $(TEST_LIBS)

junk_files += \
	$(test_activity_monitor_SOURCES:.vala=.c) \
	test_activity_monitor_vala.stamp


# Unit tests for breaks

TEST_PROGS += test-breaks

test_breaks_SOURCES = \
	tests.vala \
	breaks/breaks_runner.vala \
	breaks/test_TimerBreakController.vala

test_breaks_LDADD = $(TEST_LIBS)

junk_files += \
	$(test_breaks_SOURCES:.vala=.c) \
	test_breaks_vala.stamp


# Unit tests for "util" convenience library in helper

TEST_PROGS += test-helper-util

test_helper_util_SOURCES = \
	tests.vala \
	helper-util/helper_util_runner.vala \
	helper-util/test_Countdown.vala \
	helper-util/test_StatefulTimer.vala

test_helper_util_LDADD = $(TEST_LIBS)

junk_files += \
	$(test_helper_util_SOURCES:.vala=.c) \
	test_helper_util_vala.stamp


noinst_PROGRAMS = $(TEST_PROGS)

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)
