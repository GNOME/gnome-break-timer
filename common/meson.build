common_sources = [
    'IBreakHelper.vala',
    'ISessionStatus.vala',
    'NaturalTime.vala'
]

common_dependencies = [
    config_lib_dep,
    gio_dep
]

common_lib = static_library(
    'common',
    sources: common_sources,
    dependencies: common_dependencies
)

common_lib_dep = declare_dependency(
    link_with: common_lib,
    include_directories: include_directories('.')
)
