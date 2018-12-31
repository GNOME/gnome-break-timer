schema_dir = join_paths(get_option('datadir'), 'glib-2.0', 'schemas')

schema_file = i18n.merge_file(
    input: 'org.gnome.break-timer.gschema.xml.in',
    output: 'org.gnome.break-timer.gschema.xml',
    po_dir: po_dir,
    install: true,
    install_dir: schema_dir
)

gnome.compile_schemas()
