# Uses common_dependencies from "src"

tests_lib_sources = [
    'tests.vala'
]

tests_lib_dependencies = [
    common_lib_dep,
    daemon_lib_dep,
    settings_lib_dep
]

tests_lib = static_library(
    'tests',
    sources: tests_lib_sources,
    dependencies: tests_lib_dependencies,
    include_directories: include_directories('.')
)

tests_lib_dep = declare_dependency(
    link_with: tests_lib,
    dependencies: tests_lib_dependencies,
    include_directories: include_directories('.')
)

subdir('common')
subdir('daemon-activity')
subdir('daemon-timerbreak')
subdir('daemon-util')

