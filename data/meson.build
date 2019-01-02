subdir('icons')

desktop_in_file = configure_file(
    input: 'org.gnome.BreakTimer.desktop.in.in',
    output: 'org.gnome.BreakTimer.desktop.in',
    configuration: build_conf
)

i18n.merge_file(
    input: desktop_in_file,
    output: 'org.gnome.BreakTimer.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'applications')
)

appdata_in_file = configure_file(
    input: 'org.gnome.BreakTimer.appdata.xml.in.in',
    output: 'org.gnome.BreakTimer.appdata.xml.in',
    configuration: build_conf
)

i18n.merge_file(
    input: appdata_in_file,
    output: 'org.gnome.BreakTimer.appdata.xml',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'metainfo')
)

i18n.merge_file(
    input: 'org.gnome.BreakTimer.gschema.xml.in',
    output: 'org.gnome.BreakTimer.gschema.xml',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)

gnome.compile_schemas()

break_timer_resources = gnome.compile_resources(
    'resources',
    'org.gnome.BreakTimer.gresource.xml',
    source_dir : '.',
    c_name : 'gnome_break_timer_resources'
)
