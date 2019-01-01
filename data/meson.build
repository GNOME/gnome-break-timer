subdir('icons')

i18n.merge_file(
    input: 'org.gnome.BreakTimer.desktop.in',
    output: 'org.gnome.BreakTimer.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'applications')
)

i18n.merge_file(
    input: 'org.gnome.BreakTimer.appdata.xml.in',
    output: 'org.gnome.BreakTimer.appdata.xml',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'metainfo')
)

i18n.merge_file(
    input: 'org.gnome.break-timer.gschema.xml.in',
    output: 'org.gnome.break-timer.gschema.xml',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)

gnome.compile_schemas()

service_conf = configuration_data()
service_conf.set('bindir', bindir)

configure_file(
    input: 'org.gnome.BreakTimer.service.in',
    output: 'org.gnome.BreakTimer.service',
    configuration: service_conf,
    install_dir: join_paths(datadir, 'dbus-1', 'services')
)

break_timer_resources = gnome.compile_resources(
    'resources',
    'org.gnome.BreakTimer.gresource.xml',
    source_dir : '.',
    c_name : 'gnome_break_timer_resources'
)
