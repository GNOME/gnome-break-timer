dbus_session_bus_services_dir = join_paths(datadir, 'dbus-1', 'services')

configure_file(
    input: 'org.gnome.BreakTimer.Settings.service.in',
    output: 'org.gnome.BreakTimer.Settings.service',
    configuration: build_conf,
    install_dir: dbus_session_bus_services_dir
)

configure_file(
    input: 'org.gnome.BreakTimer.Daemon.service.in',
    output: 'org.gnome.BreakTimer.Daemon.service',
    configuration: build_conf,
    install_dir: dbus_session_bus_services_dir
)
