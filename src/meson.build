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

main_lib_sources = files(
    'activity/ActivityMonitorBackend.vala',
    'activity/ActivityMonitor.vala',
    'activity/MutterActivityMonitorBackend.vala',
    'activity/UserActivity.vala',
    'Application.vala',
    'break/BreakController.vala',
    'break/BreakType.vala',
    'break/BreakView.vala',
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

main_lib_sources += files(
    'settings/break/BreakInfoWidget.vala',
    'settings/break/BreakSettingsWidget.vala',
    'settings/break/BreakStatusWidget.vala',
    'settings/BreakSettingsDialog.vala',
    'settings/MainWindow.vala',
    'settings/microbreak/MicroBreakInfoWidget.vala',
    'settings/microbreak/MicroBreakSettingsWidget.vala',
    'settings/microbreak/MicroBreakStatusWidget.vala',
    'settings/panels/StatusPanel.vala',
    'settings/panels/WelcomePanel.vala',
    'settings/restbreak/RestBreakInfoWidget.vala',
    'settings/restbreak/RestBreakSettingsWidget.vala',
    'settings/restbreak/RestBreakStatusWidget.vala',
    'settings/timerbreak/TimerBreakSettingsWidget.vala',
    'settings/timerbreak/TimerBreakStatusWidget.vala',
    'settings/widgets/BreakConfigurationChooser.vala',
    'settings/widgets/CircleCounter.vala',
    'settings/widgets/OverlayArrow.vala',
    'settings/widgets/TimeChooserRow.vala',
    'settings/widgets/Transition.vala'
)

main_lib_dependencies = [
    cairo_dep,
    config_lib_dep,
    gio_dep,
    gio_unix_dep,
    gsound_dep,
    libadwaita_dep,
    gtk_dep,
    json_glib_dep,
    m_dep,
    posix_dep,
    common_lib_dep
]

main_lib = static_library(
    'daemon',
    sources: main_lib_sources,
    dependencies: main_lib_dependencies,
    include_directories: include_directories('.')
)

main_lib_dep = declare_dependency(
    link_with: main_lib,
    dependencies: main_lib_dependencies,
    include_directories: include_directories('.')
)

main_exe_sources = files(
    'main.vala'
)

executable(
    'gnome-break-timer',
    sources : [
        main_exe_sources
    ],
    dependencies : [
        main_lib_dep,
        break_timer_resources_dep
    ],
    install: true,
    install_dir: bindir
)


