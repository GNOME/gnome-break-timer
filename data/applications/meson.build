applications_dir = join_paths(datadir, 'applications')

desktop_file_validate = find_program('desktop-file-validate', required: false)

settings_desktop_file = i18n.merge_file(
    input: 'org.gnome.BreakTimer.Settings.desktop.in',
    output: 'org.gnome.BreakTimer.Settings.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: applications_dir
)

if desktop_file_validate.found()
    test(
        'Validate desktop file',
        desktop_file_validate,
        args: [settings_desktop_file]
    )
endif

daemon_desktop_file = i18n.merge_file(
    input: 'org.gnome.BreakTimer.desktop.in',
    output: 'org.gnome.BreakTimer.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: applications_dir
)

if desktop_file_validate.found()
    test(
        'Validate desktop file',
        desktop_file_validate,
        args: [daemon_desktop_file]
    )
endif
