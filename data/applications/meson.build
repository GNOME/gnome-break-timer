applications_dir = join_paths(datadir, 'applications')

desktop_file_validate = find_program('desktop-file-validate', required: false)

settings_desktop_file = i18n.merge_file(
    input: configure_file(
        input: 'org.gnome.BreakTimer.Settings.desktop.in.in',
        output: 'org.gnome.BreakTimer.Settings.desktop.in',
        configuration: build_conf,
    ),
    output: settings_application_id + '.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: applications_dir
)

if desktop_file_validate.found()
    test(
        'Validate org.gnome.BreakTimer.Settings.desktop',
        desktop_file_validate,
        args: [settings_desktop_file]
    )
endif

daemon_desktop_file = i18n.merge_file(
    input: configure_file(
        input: 'org.gnome.BreakTimer.Daemon.desktop.in.in',
        output: 'org.gnome.BreakTimer.Daemon.desktop.in',
        configuration: build_conf,
    ),
    output: daemon_application_id + '.desktop',
    type: 'desktop',
    po_dir: po_dir,
    install: true,
    install_dir: applications_dir
)

if desktop_file_validate.found()
    test(
        'Validate org.gnome.BreakTimer.Daemon.desktop',
        desktop_file_validate,
        args: [daemon_desktop_file]
    )
endif
