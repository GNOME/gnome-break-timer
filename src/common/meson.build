common_sources = files(
    'IBreakDaemon.vala',
    'ISessionStatus.vala',
    'NaturalTime.vala'
)

common_dependencies = [
    gio_dep,
    config_lib_dep
]

common_lib = static_library(
    'common',
    sources: common_sources,
    dependencies: common_dependencies,
    include_directories: include_directories('.')
)

common_lib_dep = declare_dependency(
    link_with: common_lib,
    include_directories: include_directories('.')
)
