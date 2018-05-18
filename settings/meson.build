# TODO: BUILD IN DATA FILES
# $(top_srcdir)/settings/resources.c: $(top_srcdir)/data/gnome-break-timer.gresource.xml $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data/ $(top_srcdir)/data/gnome-break-timer.gresource.xml)
#     $(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data/ --generate-source $<

settings_sources = [
    build_config,
    'BreakManager.vala',
    'BreakSettingsDialog.vala',
    'BreakType.vala',
    'CircleCounter.vala',
    'MainWindow.vala',
    'MicroBreakType.vala',
    'OverlayArrow.vala',
    'RestBreakType.vala',
    'SettingsApplication.vala',
    'TimeChooser.vala',
    'TimerBreakType.vala'
]

settings_dependencies = [
    cairo_dep,
    gtk_dep,
    gio_dep,
    gio_unix_dep,
    # gee_dep,
    common_dep
]

settings_lib = static_library(
    'settings',
    sources: settings_sources,
    dependencies: settings_dependencies
)

settings_dep = declare_dependency(
    link_with: settings_lib
)
