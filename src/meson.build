configure_file(
    output: 'config.h',
    configuration: build_conf
)

config_lib = valac.find_library(
    'config',
    dirs: meson.source_root()
)

config_lib_dep = declare_dependency(
    dependencies: config_lib,
    include_directories: include_directories('.')
)

subdir('common')
subdir('settings')
subdir('helper')