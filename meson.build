project('gnome-break-timer', 'vala', 'c')

cairo_dep = dependency('cairo')
# gee_dep = dependency('gee-0.8')
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

build_config_data = configuration_data()
build_config_data.set('VERSION', '1.2.3')

build_config = configure_file(
    input : 'config.vala.in',
    output : 'config.vala',
    configuration : build_config_data
)

subdir('common')
subdir('settings')
subdir('helper')

main_sources = [
    'helper/main.vala'
]

main_dependencies = [
    glib_dep,
    gobject_dep
]

executable(
    'gnome-break-timer-service',
    sources : main_sources,
    dependencies : main_dependencies
)
