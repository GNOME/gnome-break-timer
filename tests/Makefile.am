include $(top_srcdir)/base.am
include $(top_srcdir)/helper/helper.am
include $(top_srcdir)/settings/settings.am

junk_files =

AM_VALAFLAGS = $(HELPER_VALAFLAGS)
AM_CPPFLAGS = $(HELPER_CFLAGS)
AM_LDFLAGS = $(HELPER_LDFLAGS)

test_%.stamp: $(HELPER_DEPENDENCIES)


# Unit tests for "libcommon" convenience library

TEST_PROGS += test-common

test_common_SOURCES = \
	tests.vala \
	common/common_runner.vala \
	common/test_NaturalTime.vala

test_common_LDADD = $(HELPER_LIBS)

junk_files += \
	$(test_common_SOURCES:.vala=.c) \
	test_common_vala.stamp


# Unit tests for "activity-monitor" convenience library

TEST_PROGS += test-activity-monitor

test_activity_monitor_SOURCES = \
	tests.vala \
	activity-monitor/activity-monitor_runner.vala \
	activity-monitor/test_ActivityMonitor.vala

test_activity_monitor_LDADD = $(HELPER_LIBS)

junk_files += \
	$(test_activity_monitor_SOURCES:.vala=.c) \
	test_activity_monitor_vala.stamp


noinst_PROGRAMS = $(TEST_PROGS)

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files)
