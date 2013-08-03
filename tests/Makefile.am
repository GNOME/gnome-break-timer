include $(top_srcdir)/base.am

TEST_PROGS += test-helper

noinst_PROGRAMS = $(TEST_PROGS)

test_helper_SOURCES = \
	tests_common.vala \
	UnitTestSuite.vala

test_helper_VALAFLAGS = $(BASE_VALAFLAGS)

test_helper_CPPFLAGS = $(AM_CPPFLAGS) \
	$(CFG_CORE_CFLAGS)

test_helper_LDADD = $(CFG_CORE_LIBS)
