helper_sources = [
    'activity-monitor/ActivityMonitor.vala',
    'activity-monitor/MutterActivityMonitorBackend.vala',
    'activity-monitor/UserActivity.vala',
    'util/Countdown.vala',
    'util/PausableTimeout.vala',
    'util/SimpleFocusManager.vala',
    'util/StatefulTimer.vala',
    'util/Util.vala',
    'break/BreakController.vala',
    'break/BreakType.vala',
    'break/BreakView.vala',
    'break/TimerBreakController.vala',
    'break/TimerBreakType.vala',
    'break/TimerBreakView.vala',
    'microbreak/MicroBreakController.vala',
    'microbreak/MicroBreakType.vala',
    'microbreak/MicroBreakView.vala',
    'restbreak/RestBreakController.vala',
    'restbreak/RestBreakType.vala',
    'restbreak/RestBreakView.vala',
    'BreakManager.vala',
    'HelperApplication.vala',
    'SessionStatus.vala',
    'UIFragment.vala',
    'UIManager.vala'
]

# TODO: Build and link activity_monitor and util subdirs

helper_dependencies = [
    common_lib_dep,
    gtk_dep,
    gio_dep,
    gio_unix_dep,
    gee_dep,
    json_glib_dep,
    libnotify_dep,
    libcanberra_dep,
    posix_dep,
    m_dep
]

helper_lib = static_library(
    'helper',
    sources: helper_sources,
    dependencies: helper_dependencies
)

helper_lib_dep = declare_dependency(
    link_with: helper_lib,
    dependencies: helper_dependencies,
    include_directories: include_directories('.')
)

helper_main_sources = [
    'main.vala',
    break_timer_resources
]

executable(
    'gnome-break-timer-service',
    sources : helper_main_sources,
    dependencies : helper_lib_dep,
    install: true,
    install_dir: bindir
)