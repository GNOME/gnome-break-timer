metainfo_dir = join_paths(datadir, 'metainfo')

metainfo_file = i18n.merge_file(
    input: 'org.gnome.BreakTimer.metainfo.xml.in',
    output: 'org.gnome.BreakTimer.metainfo.xml',
    type: 'xml',
    po_dir: po_dir,
    install: true,
    install_dir: metainfo_dir
)

appstream_util = find_program('appstream-util', required: false)

if appstream_util.found()
    test(
        'Validate org.gnome.BreakTimer.metainfo.xml',
        appstream_util,
        args: ['validate', '--nonet', metainfo_file]
    )
endif
