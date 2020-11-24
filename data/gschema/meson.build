glib_compile_schemas = find_program('glib-compile-schemas', required: false)

gschema_file = i18n.merge_file(
    input: configure_file(
        input: 'org.gnome.BreakTimer.gschema.xml.in.in',
        output: 'org.gnome.BreakTimer.gschema.xml.in',
        configuration: build_conf,
    ),
    output: daemon_application_id + '.gschema.xml',
    po_dir: po_dir,
    install: true,
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)

gnome.compile_schemas()

if glib_compile_schemas.found()
    test(
        'Validate org.gnome.BreakTimer.gschema.xml',
        glib_compile_schemas,
        args: ['--dry-run', join_paths(datadir, 'glib-2.0', 'schemas')]
    )
endif
