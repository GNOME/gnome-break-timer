dbus_session_bus_services_dir = join_paths(datadir, 'dbus-1', 'services')

configure_file(
    input: 'org.gnome.BreakTimer.Settings.service.in',
    output: settings_application_id + '.service',
    configuration: build_conf,
    install_dir: dbus_session_bus_services_dir
)

configure_file(
    input: 'org.gnome.BreakTimer.Daemon.service.in',
    output: daemon_application_id + '.service',
    configuration: build_conf,
    install_dir: dbus_session_bus_services_dir
)
