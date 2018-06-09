helper_sources = [
    build_config,
    'break/BreakController.vala',
    'break/BreakType.vala',
    'break/BreakView.vala',
    'break/TimerBreakController.vala',
    'break/TimerBreakType.vala',
    'break/TimerBreakStatusWidget.vala',
    'break/TimerBreakView.vala',
    'microbreak/MicroBreakController.vala',
    'microbreak/MicroBreakType.vala',
    'microbreak/MicroBreakView.vala',
    'restbreak/RestBreakController.vala',
    'restbreak/RestBreakType.vala',
    'restbreak/RestBreakView.vala',
    'BreakManager.vala',
    'HelperApplication.vala',
    'ScreenOverlay.vala',
    'SessionStatus.vala',
    'UIManager.vala',
    'main.vala'
]

# TODO: Build and link activity_monitor and util subdirs

helper_dependencies = [
    gtk_dep,
    gio_dep,
    gio_unix_dep,
    gee_dep,
    json_glib_dep,
    libcanberra_dep,
    libcanberra_gtk_dep,
    libnotify_dep,
    # posix_dep,
    common_dep
]

helper_lib = static_library(
    'helper',
    sources: helper_sources,
    dependencies: helper_dependencies
)

helper_dep = declare_dependency(
    link_with: helper_lib
)

main_sources = [
    'helper/main.vala'
]

main_dependencies = [
    glib_dep,
    gobject_dep
]

executable(
    'gnome-break-timer-service',
    sources : main_sources,
    dependencies : main_dependencies
)

