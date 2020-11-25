common_lib_sources = files(
    'IBreakTimer_TimerBreak.vala',
    'IBreakTimer.vala',
    'IFreedesktopApplication.vala',
    'IGnomeScreenSaver.vala',
    'IMutterIdleMonitor.vala',
    'IPortalBackground.vala',
    'IPortalRequest.vala',
    'ISessionStatus.vala',
    'NaturalTime.vala',
    'TimeUnit.vala'
)

common_lib_dependencies = [
    gio_dep,
    config_lib_dep
]

common_lib = static_library(
    'common',
    sources: common_lib_sources,
    dependencies: common_lib_dependencies,
    include_directories: include_directories('.')
)

common_lib_dep = declare_dependency(
    link_with: common_lib,
    include_directories: include_directories('.')
)
