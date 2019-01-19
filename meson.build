project('gnome-break-timer', ['vala', 'c'],
    version: '1.0-dev',
    license: 'GPL3+'
)

gnome = import('gnome')
i18n = import('i18n')

valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

cairo_dep = dependency('cairo')
gee_dep = dependency('gee-0.8')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0')
json_glib_dep = dependency('json-glib-1.0')
libnotify_dep = dependency('libnotify')
libcanberra_dep = dependency('libcanberra')

posix_dep = valac.find_library('posix')
m_dep = cc.find_library('m', required : false)

gettext_package = meson.project_name()
po_dir = join_paths(meson.source_root(), 'po')
src_dir = join_paths(meson.source_root(), 'src')

prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
libexecdir = join_paths(prefix, get_option('libexecdir'))
locale_dir = join_paths(prefix, get_option('localedir'))

application_icon = 'org.gnome.BreakTimer'
application_url = 'https://wiki.gnome.org/Apps/BreakTimer'
settings_application_id = 'org.gnome.BreakTimer'
helper_application_id = 'org.gnome.BreakTimer.Helper'
helper_bus_name = 'org.gnome.BreakTimer.Helper'
helper_object_path = '/org/gnome/BreakTimer'
helper_break_object_base_path = '/org/gnome/BreakTimer/'

build_conf = configuration_data()
build_conf.set_quoted('GETTEXT_PACKAGE', gettext_package)
build_conf.set_quoted('LOCALE_DIR', locale_dir)
build_conf.set_quoted('PROJECT_NAME', meson.project_name())
build_conf.set_quoted('PROJECT_VERSION', meson.project_version())
build_conf.set_quoted('APPLICATION_ICON', application_icon)
build_conf.set_quoted('APPLICATION_URL', application_url)
build_conf.set_quoted('SETTINGS_APPLICATION_ID', settings_application_id)
build_conf.set_quoted('HELPER_APPLICATION_ID', helper_application_id)
build_conf.set_quoted('HELPER_BUS_NAME', helper_bus_name)
build_conf.set_quoted('HELPER_OBJECT_PATH', helper_object_path)
build_conf.set_quoted('HELPER_BREAK_OBJECT_BASE_PATH', helper_break_object_base_path)

add_project_arguments(['-DGETTEXT_PACKAGE="' + gettext_package + '"'], language: 'c')
add_project_arguments(['--vapidir', src_dir], language: 'vala')

run_script_conf = configuration_data()
run_script_conf.set('BINDIR', bindir)

configure_file(
    input: 'gnome-break-timer.sh.in',
    output: 'gnome-break-timer',
    configuration: run_script_conf,
    install: true,
    install_dir: bindir
)

subdir('po')
subdir('data')
subdir('src')

meson.add_install_script('build-aux/meson/postinstall.py')