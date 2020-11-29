config_file = configure_file(
    output: 'config.h',
    configuration: build_conf_quoted
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

main_exe_sources = files(
    'Application.vala',
    'main.vala'
)

executable(
    'gnome-break-timer',
    sources : [
        main_exe_sources
    ],
    dependencies : [
        daemon_lib_dep,
        settings_lib_dep,
        break_timer_resources_dep
    ],
    install: true,
    install_dir: bindir
)
