AM_CPPFLAGS = \
	$(BRAINBREAK_CFLAGS) \
	-include $(CONFIG_HEADER)

noinst_LTLIBRARIES = \
	libnatural_time.la

libnatural_time_la_SOURCES = \
	NaturalTime.vala

libnatural_time_la_LIBADD = \
	$(BRAINBREAK_LIBS)

libnatural_time_la_VALAFLAGS = \
	--library natural_time \
	--vapi natural_time.vapi \
	-H natural_time.h

junk_files = \
	$(libnatural_time_la_SOURCES:.vala=.c) \
	libnatural_time_la_vala.stamp

dist-hook:
	cd $(distdir) && rm -f $(junk_files)

CLEANFILES = \
	$(junk_files) \
	natural_time.vapi \
	natural_time.h

