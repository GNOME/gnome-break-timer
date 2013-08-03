include $(top_srcdir)/base.am
include $(top_srcdir)/common/common.am

TEST_PROGS += test-common
noinst_PROGRAMS = $(TEST_PROGS)

# Unit tests for "libcommon" convenience library

test_common_SOURCES = \
	tests.vala \
	unit/common.vala

test_common_VALAFLAGS = $(COMMON_VALAFLAGS) \
	$(top_builddir)/common/common.vapi

test_common_CPPFLAGS = $(COMMON_CFLAGS)

test_common_LDADD = $(COMMON_LDADD) \
	$(top_builddir)/common/libcommon.la

test_common_vala.stamp: \
	$(top_builddir)/common/libcommon.la
