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
