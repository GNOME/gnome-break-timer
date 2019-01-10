project('gnome-break-timer', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

env = environment()

cairo_dep = dependency('cairo')
gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0')
json_glib_dep = dependency('json-glib-1.0')
libnotify_dep = dependency('libnotify')

posix_dep = valac.find_library('posix')
m_dep = cc.find_library('m', required : false)

gettext_package = meson.project_name()
po_dir = join_paths(meson.source_root(), 'po')

prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
libexecdir = join_paths(prefix, get_option('libexecdir'))

package_url = 'https://wiki.gnome.org/Apps/BreakTimer'
settings_desktop_id = 'org.gnome.BreakTimer'
helper_desktop_id = 'org.gnome.BreakTimer.Helper'
helper_bus_name = 'org.gnome.BreakTimer.Helper'
helper_object_path = '/org/gnome/BreakTimer'
helper_break_object_base_path = '/org/gnome/BreakTimer/'

build_conf = configuration_data()
build_conf.set('BINDIR', bindir)
build_conf.set('GETTEXT_PACKAGE', gettext_package)
build_conf.set('PACKAGE_NAME', meson.project_name())
build_conf.set('PACKAGE_VERSION', meson.project_version())
build_conf.set('PACKAGE_URL', package_url)
build_conf.set('VERSION', meson.project_version())
build_conf.set('SETTINGS_DESKTOP_ID', settings_desktop_id)
build_conf.set('HELPER_DESKTOP_ID', helper_desktop_id)
build_conf.set('HELPER_BUS_NAME', helper_bus_name)
build_conf.set('HELPER_OBJECT_PATH', helper_object_path)
build_conf.set('HELPER_BREAK_OBJECT_BASE_PATH', helper_break_object_base_path)

build_conf_quoted = configuration_data()
build_conf_quoted.set_quoted('BINDIR', bindir)
build_conf_quoted.set_quoted('GETTEXT_PACKAGE', gettext_package)
build_conf_quoted.set_quoted('PACKAGE_NAME', meson.project_name())
build_conf_quoted.set_quoted('PACKAGE_VERSION', meson.project_version())
build_conf_quoted.set_quoted('PACKAGE_URL', package_url)
build_conf_quoted.set_quoted('VERSION', meson.project_version())
build_conf_quoted.set_quoted('SETTINGS_DESKTOP_ID', settings_desktop_id)
build_conf_quoted.set_quoted('HELPER_DESKTOP_ID', helper_desktop_id)
build_conf_quoted.set_quoted('HELPER_BUS_NAME', helper_bus_name)
build_conf_quoted.set_quoted('HELPER_OBJECT_PATH', helper_object_path)
build_conf_quoted.set_quoted('HELPER_BREAK_OBJECT_BASE_PATH', helper_break_object_base_path)

add_project_arguments('-DGETTEXT_PACKAGE="' + gettext_package + '"', language: 'c')

configure_file(
    output: 'config.h',
    configuration: build_conf_quoted
)

config_lib = valac.find_library(
    'config',
    dirs: meson.source_root()
)

config_lib_dep = declare_dependency(
    dependencies: config_lib,
    include_directories: include_directories('.')
)

configure_file(
    input: 'gnome-break-timer.sh.in',
    output: 'gnome-break-timer',
    configuration: build_conf,
    install: true,
    install_dir: bindir
)

subdir('po')
subdir('common')
subdir('data')
subdir('settings')
subdir('helper')

meson.add_install_script('build-aux/meson/postinstall.py')