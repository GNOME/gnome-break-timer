config_file = configure_file(
    output: 'config.h',
    configuration: build_conf
)

config_lib = valac.find_library(
    'config',
    dirs: meson.current_source_dir()
)

config_lib_dep = declare_dependency(
    sources: config_file,
    dependencies: config_lib,
    include_directories: include_directories('.')
)

subdir('common')
subdir('settings')
subdir('daemon')

common_dependencies = [
    cairo_dep,
    config_lib_dep,
    gee_dep,
    gio_dep,
    gio_unix_dep,
    gtk_dep,
    json_glib_dep,
    gsound_dep,
    libnotify_dep,
    m_dep,
    posix_dep,
    common_lib_dep,
    break_timer_resources_dep
]

executable(
    'gnome-break-timer-settings',
    sources : [
        settings_sources
    ],
    dependencies : common_dependencies,
    install: true,
    install_dir: bindir
)

executable(
    'gnome-break-timer-daemon',
    sources : [
        daemon_sources
    ],
    dependencies : common_dependencies,
    install: true,
    install_dir: bindir
)
