AC_INIT([gnome-break-timer],
	[1.0],
	[http://bugs.launchpad.net/brainbreak],
	[gnome-break-timer],
	[https://wiki.gnome.org/GnomeBreakTimer])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
LT_INIT
AM_MAINTAINER_MODE
AC_CONFIG_HEADERS([config.h])

AC_PATH_PROG(VALAC, valac, valac)
AC_SUBST(VALAC)

AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

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

GLIB_REQUIRED=2.36.0
GTK_REQUIRED=3.8.0
GTK_RECOMMENDED=3.9.4

PKG_CHECK_MODULES([CFG_CORE], [
	glib-2.0 >= $GLIB_REQUIRED
	gobject-2.0 >= $GLIB_REQUIRED
	gee-1.0 >= 0.6.2
	gio-2.0 >= 2.30.0
	gio-unix-2.0 >= 2.30.0
	gtk+-3.0 >= $GTK_REQUIRED
	json-glib-1.0 >= 0.16.0
])

PKG_CHECK_MODULES([CFG_HELPER], [
	libcanberra >= 0.28
	libcanberra-gtk3 >= 0.28
	libnotify >= 0.4.5
])

PKG_CHECK_MODULES([CFG_SETTINGS], [
	cairo >= 1.12.14
])

PKG_CHECK_MODULES([CFG_ACTIVITY_MONITOR], [
	gdk-x11-3.0 >= $GTK_REQUIRED
])

PKG_CHECK_MODULES([CFG_ACTIVITY_MONITOR_BACKEND], [
	x11 >= 1.4.99.1
	xi >= 1.5.99.3
	xtst >= 1.2.0
])

PKG_CHECK_MODULES(
	[CFG_GTK], [gtk+-3.0 >= $GTK_RECOMMENDED], [GTK_MIN_VERSION=3.10],
	[PKG_CHECK_MODULES(
		[CFG_GTK], [gtk+-3.0 >= $GTK_REQUIRED], [GTK_MIN_VERSION=3.8]
	)]
)

LIBGD_INIT([header-bar stack revealer vapi])



# Some helpful constants that are available to the application

AM_CONDITIONAL([HAS_GTK_3_10], [test $GTK_MIN_VERSION = 3.10])

AC_DEFINE(SETTINGS_DESKTOP_ID, "gnome-break-timer.desktop", [Name of the .desktop file used for the settings application])
AC_DEFINE(HELPER_DESKTOP_ID, "gnome-break-timer-service.desktop", [Name of the .desktop file used for the helper service])



AC_CONFIG_FILES([Makefile
	common/Makefile
	settings/Makefile
	helper/Makefile
	helper/activity-monitor/Makefile
	helper/util/Makefile
	data/Makefile
	data/icons/Makefile
	libgd/Makefile
	po/Makefile.in
	tests/Makefile
])

AC_OUTPUT
