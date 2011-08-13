import os
import Utils
import Options
from buildj import *

APPNAME = None
VERSION = None

#BuilDj Tool -> Waf tool

####### Utils ##################################################################
def parse_project_file (project_file=DEFAULT_BUILDJ_FILE):
	try:
		project = ProjectFile (project_file)
		set_project_info(project)
	except ValueError, e:
		raise Utils.WscriptError (str(e), project_file)
	
	return project

def set_project_info (project):
		global APPNAME, VERSION
		APPNAME = project.get_project_name ()
		VERSION = project.get_project_version ()

def set_crosscompile_env (prefix, env={}):
	for tool in CC_TOOLCHAIN:
		if tool not in env:
			env[tool] = prefix + "-" + CC_TOOLCHAIN[tool]
		# Setup various target file patterns
	
	#Windows Prefix/suffix (what about bcc and icc?)
	if ('mingw'  in prefix or
	    'msvc'   in prefix or
	    'cygwin' in prefix or
	    'msys'   in prefix):
		if not 'staticlib_PATTERN' in env:
			env['staticlib_PATTERN'] = '%s.lib'
		if not 'shlib_PATTERN' in env:
			env['shlib_PATTERN'] = '%s.dll'
		if not 'program_PATTERN' in env:
			env['program_PATTERN'] = '%s.exe'
		
	if 'PKG_CONFIG_LIBDIR' not in env:
		env['PKG_CONFIG_LIBDIR'] = '/usr/'+prefix+'/lib'

################################################################################
## WAF TARGETS 
################################################################################

#TODO: Cache json values? Worth it?
#TODO: Allow definition of different json filename

def options (opt):
	project = parse_project_file ()

	#BuilDj options
	opt.add_option('--buildj-file', action='store', default="project.js", help='Sets the BuilDj file.')	
	opt.add_option('--target-platform', action='store', default=None, help='Sets the target platform tuple used as a prefix for the gcc toolchain.')

	#Project options
	for option in project.get_options ():
		opt.add_option("--"+option.get_name (), **option.get_option_arguments ())
	
	#Infered options
	included_tools = []
	for tool in project.get_tools ():
		tool = WAF_TOOLS[tool]
		if tool not in included_tools:
			opt.tool_options (tool)
			included_tools.append (tool)
			

def configure (conf):
	#Cross compile tests
	if Options.options.target_platform:
		set_crosscompile_env (Options.options.target_platform, conf.env)
	
	project = parse_project_file ()
	
	for tool in project.get_tools ():
		conf.check_tool (WAF_TOOLS[tool])

	#We check all the tools' required packages
	for package in project.get_packages_required ():
		conf.check_cfg (**package.get_check_pkg_args ())

	#FIXME: This should be done upstream
	if "vala" in project.get_tools():
		if not conf.env.HAVE_GLIB_2_0:
			conf.check_cfg (package="glib-2.0", mandatory=True)

	conf.write_config_header()

def build(bld):
	project = parse_project_file ()

	for target in project.get_targets ():
		args = target.get_build_arguments ()
		args['path'] = bld.srcnode.find_dir(target.get_path())
		bld.new_task_gen (**args)

		install_files = target.get_install_files ()
		if install_files:
			bld.install_files (target.get_install_path (), install_files)
