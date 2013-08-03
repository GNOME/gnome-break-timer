include $(top_srcdir)/base.am

TEST_PROGS += test-common
noinst_PROGRAMS = $(TEST_PROGS)

# Unit tests for "libcommon" convenience library

test_common_SOURCES = \
	tests.vala \
	unit/common.vala

test_common_VALAFLAGS = $(BASE_VALAFLAGS) \
	--pkg gio-2.0 \
	$(top_builddir)/common/common.vapi

test_common_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS)

test_common_LDADD = $(BASE_LIBS) \
	$(top_builddir)/common/libcommon.la

test_common_vala.stamp: \
	$(top_builddir)/common/libcommon_la_vala.stamp
