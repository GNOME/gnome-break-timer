AC_INIT([brainbreak],
	[1.0],
	[http://bugs.launchpad.net/brainbreak],
	[brainbreak],
	[https://launchpad.net/brainbreak])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
LT_INIT
AM_MAINTAINER_MODE
AC_CONFIG_HEADERS([config.h])

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

IT_PROG_INTLTOOL(0.40)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST([GETTEXT_PACKAGE])
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE",[The name of the gettext domain])

GLIB_GSETTINGS

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

GLIB_REQUIRED=2.32.0
GTK_REQUIRED=3.4.0

PKG_CHECK_MODULES(BRAINBREAK, [
	gdk-x11-3.0 >= $GTK_REQUIRED
	gee-1.0 >= 0.6.2
	gio-2.0 >= 2.30.0
	gio-unix-2.0 >= 2.30.0
	glib-2.0 >= $GLIB_REQUIRED
	gobject-2.0 >= $GLIB_REQUIRED
	gtk+-3.0 >= $GTK_REQUIRED
	libcanberra >= 0.30
	libnotify >= 0.4.5
	x11 >= 1.4.99.1
	xi >= 1.5.99.3
	xtst >= 1.2.0
])
AC_SUBST(BRAINBREAK_CFLAGS)
AC_SUBST(BRAINBREAK_LIBS)

AC_SUBST([BRAINBREAK_VALAFLAGS], "--pkg glib-2.0 --target-glib=$GLIB_REQUIRED")

AC_CONFIG_FILES([Makefile
	common/Makefile
	settings/Makefile
	helper/Makefile
	helper/activity-monitor/Makefile
	helper/util/Makefile
	data/Makefile
	po/Makefile.in])

AC_OUTPUT
