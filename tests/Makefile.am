include $(top_srcdir)/base.am

TEST_PROGS += test-helper

noinst_PROGRAMS = $(TEST_PROGS)

test_helper_SOURCES = \
	tests_common.vala \
	UnitTestSuite.vala

test_helper_VALAFLAGS = $(BASE_VALAFLAGS)

test_helper_CPPFLAGS = $(AM_CPPFLAGS) \
	$(BASE_CFLAGS)

test_helper_LDADD = $(BASE_LIBS)
