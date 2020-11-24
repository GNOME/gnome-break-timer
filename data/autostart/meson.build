autostart_dir = join_paths(sysconf_dir, 'xdg', 'autostart')

desktop_file_validate = find_program('desktop-file-validate', required: false)

daemon_autostart_desktop_file = i18n.merge_file(
    input: configure_file(
        input: 'org.gnome.BreakTimer.desktop.in.in',
        output: 'org.gnome.BreakTimer.desktop.in',
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
        'Validate org.gnome.BreakTimer.desktop (autostart)',
        desktop_file_validate,
        args: [daemon_autostart_desktop_file]
    )
endif
