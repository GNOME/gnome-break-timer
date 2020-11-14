autostart_dir = join_paths(sysconf_dir, 'xdg', 'autostart')

desktop_file_validate = find_program('desktop-file-validate', required: false)

daemon_autostart_desktop_file = i18n.merge_file(
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
        args: [daemon_autostart_desktop_file]
    )
endif
