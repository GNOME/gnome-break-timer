settings_lib_sources = files(
    'Application.vala',
    'break/BreakInfoWidget.vala',
    'break/BreakSettingsWidget.vala',
    'break/BreakStatusWidget.vala',
    'break/BreakType.vala',
    'BreakManager.vala',
    'BreakSettingsDialog.vala',
    'MainWindow.vala',
    'microbreak/MicroBreakInfoWidget.vala',
    'microbreak/MicroBreakSettingsWidget.vala',
    'microbreak/MicroBreakStatusWidget.vala',
    'microbreak/MicroBreakType.vala',
    'panels/StatusPanel.vala',
    'panels/WelcomePanel.vala',
    'restbreak/RestBreakInfoWidget.vala',
    'restbreak/RestBreakSettingsWidget.vala',
    'restbreak/RestBreakStatusWidget.vala',
    'restbreak/RestBreakType.vala',
    'timerbreak/TimerBreakSettingsWidget.vala',
    'timerbreak/TimerBreakStatusWidget.vala',
    'timerbreak/TimerBreakType.vala',
    'widgets/BreakConfigurationChooser.vala',
    'widgets/CircleCounter.vala',
    'widgets/OverlayArrow.vala',
    'widgets/TimeChooserRow.vala',
    'widgets/Transition.vala'
)

settings_lib_dependencies = [
    cairo_dep,
    config_lib_dep,
    gio_dep,
    gio_unix_dep,
    gtk_dep,
    json_glib_dep,
    gsound_dep,
    libadwaita_dep,
    m_dep,
    posix_dep,
    common_lib_dep
]

settings_lib = static_library(
    'settings',
    sources: settings_lib_sources,
    dependencies: settings_lib_dependencies,
    include_directories: include_directories('.')
)

settings_lib_dep = declare_dependency(
    link_with: settings_lib,
    dependencies: settings_lib_dependencies,
    include_directories: include_directories('.')
)

settings_exe_sources = files(
    'main.vala'
)

executable(
    'gnome-break-timer-settings',
    sources : [
        settings_exe_sources
    ],
    dependencies : [
        settings_lib_dep,
        break_timer_resources_dep
    ],
    install: true,
    install_dir: bindir
)
