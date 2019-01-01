project('gnome-break-timer', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

valac = meson.get_compiler('vala')

env = environment()

cairo_dep = dependency('cairo')
gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0')
json_glib_dep = dependency('json-glib-1.0')
libcanberra_dep = dependency('libcanberra')
libcanberra_gtk_dep = dependency('libcanberra-gtk')
libnotify_dep = dependency('libnotify')
# posix_dep = dependency('posix')

gettext_package = meson.project_name()
po_dir = join_paths(meson.source_root(), 'po')

prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', gettext_package)
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PACKAGE_URL', 'TODO')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('HELPER_DESKTOP_ID', 'TODO')
conf.set_quoted('SETTINGS_DESKTOP_ID', 'TODO')

add_project_arguments('-DGETTEXT_PACKAGE="' + gettext_package + '"', language: 'c')

configure_file(
    output: 'config.h',
    configuration: conf
)

config_lib = valac.find_library(
    'config',
    dirs: meson.source_root()
)

config_lib_dep = declare_dependency(
    dependencies: config_lib,
    include_directories: include_directories('.')
)

subdir('po')
subdir('common')
subdir('data')
subdir('settings')
# subdir('helper')

meson.add_install_script('build-aux/meson/postinstall.py')
