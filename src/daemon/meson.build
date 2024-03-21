daemon_lib_sources = files(
    'activity/ActivityMonitorBackend.vala',
    'activity/ActivityMonitor.vala',
    'activity/MutterActivityMonitorBackend.vala',
    'activity/UserActivity.vala',
    'Application.vala',
    'break/BreakController.vala',
    'break/BreakType.vala',
    'break/BreakView.vala',
    'BreakManagerDBusObject.vala',
    'BreakManager.vala',
    'microbreak/MicroBreakController.vala',
    'microbreak/MicroBreakType.vala',
    'microbreak/MicroBreakView.vala',
    'restbreak/RestBreakController.vala',
    'restbreak/RestBreakType.vala',
    'restbreak/RestBreakView.vala',
    'SessionStatus.vala',
    'timerbreak/TimerBreakController.vala',
    'timerbreak/TimerBreakDBusObject.vala',
    'timerbreak/TimerBreakType.vala',
    'timerbreak/TimerBreakView.vala',
    'UIFragment.vala',
    'UIManager.vala',
    'util/Countdown.vala',
    'util/PausableTimeout.vala',
    'util/SimpleFocusManager.vala',
    'util/StatefulTimer.vala'
)

daemon_lib_dependencies = [
    cairo_dep,
    config_lib_dep,
    gio_dep,
    gio_unix_dep,
    gsound_dep,
    gtk_dep,
    json_glib_dep,
    m_dep,
    posix_dep,
    common_lib_dep
]

daemon_lib = static_library(
    'daemon',
    sources: daemon_lib_sources,
    dependencies: daemon_lib_dependencies,
    include_directories: include_directories('.')
)

daemon_lib_dep = declare_dependency(
    link_with: daemon_lib,
    dependencies: daemon_lib_dependencies,
    include_directories: include_directories('.')
)

daemon_exe_sources = files(
    'main.vala'
)

executable(
    'gnome-break-timer-daemon',
    sources : [
        daemon_exe_sources
    ],
    dependencies : [
        daemon_lib_dep,
        break_timer_resources_dep
    ],
    install: true,
    install_dir: bindir
)
