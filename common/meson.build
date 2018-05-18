common_sources = [
    'IBreakHelper.vala',
    'ISessionStatus.vala',
    'NaturalTime.vala'
]

common_dependencies = [
    gio_dep
]

common_lib = static_library(
    'common',
    sources: common_sources,
    dependencies: common_dependencies
)

common_dep = declare_dependency(
    link_with: common_lib
)

