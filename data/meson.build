subdir('applications')
subdir('autostart')
subdir('dbus')
subdir('gschema')
subdir('icons')
subdir('metainfo')
subdir('ui')

break_timer_resources = gnome.compile_resources(
    'resources',
    configure_file(
        input: 'org.gnome.BreakTimer.gresource.xml.in',
        output: application_id + '.gresource.xml',
        configuration: build_conf,
    ),
    source_dir: meson.current_build_dir(),
    c_name: 'gnome_break_timer_resources',
    dependencies: [
        blueprints
    ]
)

break_timer_resources_dep = declare_dependency(
    sources: [break_timer_resources],
    include_directories: include_directories('.')
)
