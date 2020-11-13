break_timer_resources = gnome.compile_resources(
    'resources',
    'org.gnome.BreakTimer.gresource.xml',
    source_dir : '.',
    c_name : 'gnome_break_timer_resources'
)

break_timer_resources_dep = declare_dependency(
    sources: [break_timer_resources],
    include_directories: include_directories('.')
)
