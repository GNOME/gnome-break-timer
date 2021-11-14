metainfo_dir = join_paths(datadir, 'metainfo')

appstream_util = find_program('appstream-util', required: false)

metainfo_file = i18n.merge_file(
    input: configure_file(
        input: 'org.gnome.BreakTimer.metainfo.xml.in.in',
        output: 'org.gnome.BreakTimer.metainfo.xml.in',
        configuration: build_conf,
    ),
    output: application_id + '.metainfo.xml',
    type: 'xml',
    po_dir: po_dir,
    install: true,
    install_dir: metainfo_dir
)

if appstream_util.found()
    test(
        'Validate org.gnome.BreakTimer.metainfo.xml',
        appstream_util,
        args: ['validate-relax', '--nonet', metainfo_file]
    )
endif
