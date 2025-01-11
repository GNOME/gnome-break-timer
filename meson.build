project('gnome-break-timer', ['vala', 'c'],
    version: '3.1.0',
    license: 'GPL3+'
)

gnome = import('gnome')
i18n = import('i18n')

valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

cairo_dep = dependency('cairo')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gsound_dep = dependency('gsound')
gtk_dep = dependency('gtk4')
json_glib_dep = dependency('json-glib-1.0')
libadwaita_dep = dependency('libadwaita-1')
libcanberra_dep = dependency('libcanberra')

posix_dep = valac.find_library('posix')
m_dep = cc.find_library('m', required : false)

gettext_package = meson.project_name()
po_dir = join_paths(meson.source_root(), 'po')
src_dir = join_paths(meson.source_root(), 'src')

prefix = get_option('prefix')
bindir = join_paths(prefix, get_option('bindir'))
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
libexecdir = join_paths(prefix, get_option('libexecdir'))
locale_dir = join_paths(prefix, get_option('localedir'))
sysconf_dir = get_option('sysconfdir')

build_profile = get_option('profile')

if build_profile == 'default'
    application_id = 'org.gnome.BreakTimer'
    version_suffix = ''
elif build_profile == 'development'
    application_id = 'org.gnome.BreakTimer.Devel'
    git = find_program('git', required : false)
    if git.found()
        git_commit = run_command('git', 'describe', '--match=""', '--always', '--dirty', check: true).stdout().strip()
        version_suffix = '-@0@'.format(git_commit)
    else
        version_suffix = '-devel'
    endif
endif

daemon_application_id = application_id + '.Daemon'
settings_application_id = application_id

application_url = 'https://gitlab.gnome.org/GNOME/gnome-break-timer/'
application_issues_url = 'https://gitlab.gnome.org/GNOME/gnome-break-timer/-/issues'
daemon_object_path = '/org/gnome/BreakTimer'

# We need a quoted version of build_conf to generate config.h in `src`, and an
# unquoted version to use configure_file with arbitrary files in `data`.

build_conf = configuration_data()

build_conf.set('GETTEXT_PACKAGE', gettext_package)
build_conf.set('LOCALE_DIR', locale_dir)
build_conf.set('BUILD_PROFILE', build_profile)
build_conf.set('PROJECT_NAME', meson.project_name())
build_conf.set('PROJECT_VERSION', meson.project_version() + version_suffix)
build_conf.set('APPLICATION_ID', application_id)
build_conf.set('APPLICATION_URL', application_url)
build_conf.set('APPLICATION_ISSUES_URL', application_issues_url)
build_conf.set('SETTINGS_APPLICATION_ID', settings_application_id)
build_conf.set('DAEMON_APPLICATION_ID', daemon_application_id)
build_conf.set('DAEMON_OBJECT_PATH', daemon_object_path)

build_conf_quoted = configuration_data()
build_conf_quoted.set_quoted('GETTEXT_PACKAGE', gettext_package)
build_conf_quoted.set_quoted('LOCALE_DIR', locale_dir)
build_conf_quoted.set_quoted('BUILD_PROFILE', build_profile)
build_conf_quoted.set_quoted('PROJECT_NAME', meson.project_name())
build_conf_quoted.set_quoted('PROJECT_VERSION', meson.project_version() + version_suffix)
build_conf_quoted.set_quoted('APPLICATION_ID', application_id)
build_conf_quoted.set_quoted('APPLICATION_URL', application_url)
build_conf_quoted.set_quoted('APPLICATION_ISSUES_URL', application_issues_url)
build_conf_quoted.set_quoted('SETTINGS_APPLICATION_ID', settings_application_id)
build_conf_quoted.set_quoted('DAEMON_APPLICATION_ID', daemon_application_id)
build_conf_quoted.set_quoted('DAEMON_OBJECT_PATH', daemon_object_path)

add_project_arguments(['-DGETTEXT_PACKAGE="' + gettext_package + '"'], language: 'c')
add_project_arguments(['--vapidir', src_dir], language: 'vala')

run_script_conf = configuration_data()
run_script_conf.set('BINDIR', bindir)

subdir('po')
subdir('data')
subdir('src')
subdir('tests')

meson.add_install_script('build-aux/meson/postinstall.py')
