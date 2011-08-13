import yaml
import re

WAF_TOOLS = {'cc':   'compiler_cc',
             'c++':  'compiler_cxx',
             'vala': 'compiler_cc vala'}

# (Tool,Type) -> Waf features map
FEATURES_MAP = {('cc', 'program'):     'c cprogram',
                ('cc', 'sharedlib'):   'c cshlib',
                ('cc', 'staticlib'):   'c cstlib',
                ('c++', 'program'):    'cxx cprogram',
                ('c++', 'sharedlib'):  'cxxshlib',
                ('c++', 'staticlib'):  'cxxstlib',
                ('vala', 'program'):   'c cprogram',
                ('vala', 'sharedlib'): 'c cshlib',
                ('vala', 'staticlib'): 'c cstlib'}

CC_TOOLCHAIN = {'ADDR2LINE': 'addr2line',
                'AS': 'as', 'CC': 'gcc', 'CPP': 'cpp',
                'CPPFILT': 'c++filt', 'CXX': 'g++',
                'DLLTOOL': 'dlltool', 'DLLWRAP': 'dllwrap',
                'GCOV': 'gcov', 'LD': 'ld', 'NM': 'nm',
                'OBJCOPY': 'objcopy', 'OBJDUMP': 'objdump',
                'READELF': 'readelf', 'SIZE': 'size',
                'STRINGS': 'strings', 'WINDRES': 'windres',
                'AR': 'ar', 'RANLIB': 'ranlib', 'STRIP': 'strip'}

DEFAULT_BUILDJ_FILE="project.yaml"

def normalize_package_name (name):
	name = name.upper ()
	nonalpha = re.compile (r'\W')
	return nonalpha.sub ('_', name)

class ProjectFile:
	def __init__ (self, project=DEFAULT_BUILDJ_FILE):
		prj = open(project)
		data = prj.read ()
		self._project = yaml.load (data)
		prj.close ()

		#TODO: try to raise some meaningful (and consistent) error
		self._project_name = self._project['project']['name']
		self._project_version = self._project['project']['version']

		self._targets = []
		for target_name, target_data in self._project['targets'].iteritems():
			self._targets.append(ProjectTarget(target_name, target_data))

		for subdir in self._project.get ('subdirs', []):
			prj = open ('%s/%s' % (subdir, project))
			data = prj.read ()
			subproject = yaml.load (data)
			for target_name, target_data in subproject['targets'].iteritems():
				assert target_name not in self._project['targets']
				if 'path' in target_data:
					path = '%s/%s' % (subdir, target_data['path'])
				else:
					path = subdir
				target_data['path'] = path
				self._project['targets'][target_name] = target_data
				self._targets.append(ProjectTarget(target_name, target_data))

	def __repr__ (self):
		enc = json.encoder.JSONEncoder ()
		return enc.encode (self._project)

	def get_project_version (self):
		return self._project_version
		
	def get_project_name (self):
		return self._project_name
		
	def get_options (self):
		project = self._project
		if not "options" in project:
			return []

		option_list = []
		for option_name in project["options"]:
			option_list.append (ProjectOption (str(option_name),
			                                   project["options"][option_name]))
		return option_list

	def get_targets (self):
		names = dict([(tgt.get_name(), tgt) for tgt in self._targets])
		deps = dict([(tgt.get_name(), tgt.get_uses()) for tgt in self._targets])
		S = [tgt for tgt in deps if not deps[tgt]]
		targets = []
		while S:
			n = S.pop(0)
			targets.append(names[n])
			for m in deps:
				if n in deps[m]:
					deps[m].remove(n)
					if not deps[m]:
						S.insert(0,m)
		return targets

	def get_tools (self):
		tools = []

		for target in self._targets:
			tool = target.get_tool ()
			if tool and tool != "data":
				tools.append (tool)
		return tools

	def get_requires (self):
		project = self._project
		if not "requires" in project:
			return
		
		return [ProjectRequirement(require, project["requires"][require])
		          for require in project["requires"]]
	
	def get_packages_required (self):
		"List of pkg-config packages required"
		requires = self.get_requires ()
		return [require for require in requires if require.get_type () == "package"]
			          
	def replace_options (self, *args):
		pass
	

class ProjectTarget(object):
	def __new__(cls, name, target):
		if not isinstance (target, dict):
			raise ValueError, "Target %s: the target argument must be a dictionary" % name

		if 'tool' in target:
			cls = TOOL_CLASS_MAP[target['tool']]
		else:
			sources = target['input']
			tools = set ()
			for src in sources:
				for tool, exts in EXT_TOOL_MAP.iteritems ():
					if any([src.endswith (ext) for ext in exts]):
						tools.add (tool)
			tools = tuple(sorted(tools))

			if len(tools) == 1:
				tool = tools[0]
			elif tools in MULTI_TOOL_MAP:
				tool = MULTI_TOOL_MAP[tools]
			else:
				raise NotImplementedError, "Target %s: you need to specify a tool"

			target['tool'] = tool
			cls = TOOL_CLASS_MAP[tool]

		return object.__new__(cls)

	def __init__(self, name, target):
		self._name   = name
		self._target = target

	def get_name (self):
		return str(self._name)

	def get_output (self):
		if "output" in self._target:
			return str(self._target["output"])
		return self.get_name()

	def get_tool (self):
		if "tool" not in self._target:
			return None

		return str(self._target["tool"])
	
	def get_type (self):
		if "type" not in self._target:
			return
		return str(self._target["type"])

	def get_path (self):
		return str(self._target.get ("path", ""))
		
	def get_features (self):
		tool = self.get_tool ()
		output_type = self.get_type ()
		if not tool or not output_type:
			#TODO: Report tool and target type needed
			return
			
		if (tool, output_type) in FEATURES_MAP:
			return FEATURES_MAP[(tool, output_type)]
		else:
			#TODO: Report lack of support for this combination
			return
	
	def _get_string_list (self, key):
		if key not in self._target:
			return []
		target_input = self._target[key]
		
		if isinstance (target_input, unicode):
			return [str(target_input),]
		elif isinstance (target_input, list):
			#TODO: Check if everything is str
			return [str(t) for t in target_input]

		#TODO: Report warning, empty input
		return []
		
	def get_input (self):
		return self._get_string_list ("input")
		
	def get_uses (self):
		return self._get_string_list ("uses")
	
	def get_version (self):
		if "version" not in self._target:
			return None
		return str(self._target["version"])
		
	def get_packages (self):
		return self._get_string_list ("packages")
	
	def get_defines (self):
		return self._get_string_list ("defines")
	
	def get_build_arguments (self):
		"WAF bld arguments dictionary"
		args = {"features": self.get_features (),
		        "source":   self.get_input (),
		        "name":     self.get_name (),
		        "target":   self.get_output ()}
		
		return args

	def get_install_files (self):
		return

	def get_install_path (self):
		return

class CcTarget (ProjectTarget):
	def get_build_arguments (self):
		args = ProjectTarget.get_build_arguments (self)

		uses = self.get_uses ()
		if uses:
			# waf vala support will modify the list if we pass one
			args["uselib_local"] = " ".join (uses)

		if self.get_type () == "sharedlib" and self.get_version ():
			args["vnum"] = self.get_version ()

		args["uselib"] = []
		for pkg in self.get_packages ():
			args["uselib"].append (normalize_package_name(pkg))
		
		defines = self.get_defines ()
		if defines:
			args["defines"] = defines

		if self.get_type () in ("sharedlib", "staticlib"):
			args["export_incdirs"] = '.'

		return args

class ValaTarget (CcTarget):
	def get_vapi (self):
		if "vapi" in self._target:
			return str (self._target["vapi"])
		
	def get_gir (self):
		if "gir" in self._target:	
			gir = str(self._target["gir"])
			
			match = re.match (".*-.*", gir)
			if match:
				return gir
				
		return None

	def get_build_arguments (self):
			"WAF bld arguments dictionary"
			args = CcTarget.get_build_arguments (self)

			packages = self.get_packages ()
			if "glib-2.0" not in packages:
				packages.append ("glib-2.0")
				
			if "uselib" in args:
				args["uselib"].append (normalize_package_name("glib-2.0"))
			else:
				args["uselib"] = [normalize_package_name("glib-2.0")]
			
			args["packages"] = packages
			
			gir = self.get_gir ()
			if gir:
				args["gir"] = gir
			
			return args

class DataTarget (ProjectTarget):
	def get_build_arguments (self):
		return {}

	def get_install_files (self):
		if "input" not in self._target:
			return []
		return self.get_input ()

	def get_install_path (self):
		return "${PREFIX}/share/" + self.get_output ()

class ProjectRequirement:
	def __init__ (self, name, requirement):
		self._name = name
		self._requirement = requirement

	def get_name (self):
		return str(self._name)
	
	def get_type (self):
		if "type" not in self._requirement:
			#TODO: Type is required
			return

		return str(self._requirement["type"])
		
	def get_version (self):
		if "version" not in self._requirement:
			return
		return str(self._requirement["version"])
		
	def is_mandatory (self):
		if "mandatory" not in self._requirement:
			return False
			
		mandatory = self._requirement["mandatory"]
		if "True" == mandatory:
			return True
		elif "False" == mandatory:
			return False
		else:
			#TODO: Warn about wrong mandatory 
			pass
		
		
	def get_check_pkg_args (self):
		"WAF check_pkg arguments dictionary"
		args = {"package": self.get_name ()}
		
		#Correctly sets the version
		if self.get_version():
			version = self.get_version()
			if version.startswith ("= "):
				args["exact_version"] = str(version[2:])
			if version.startswith ("== "):
				args["exact_version"] = str(version[3:])
			elif version.startswith (">= "):
				args["atleast_version"] = str(version[3:])
			elif version.startswith ("<= "):
				args["max_version"] = str(version[3:])
			else:
				#FIXME: < and > are supported as an argument but not by waf
				#TODO: Warn that >= is recommended
				args["atleast_version"] = str(version)
				pass
				
		if self.get_type () == "package":
			args["mandatory"] = self.is_mandatory ()
			
		args["args"] = "--cflags --libs"
		
		args["uselib_store"] = normalize_package_name (self.get_name ())

		return args

class ProjectOption:
	def __init__ (self, name, option):
		self._name = str(name)
		self._option = option
	
		if not "default" in option:
				#TODO: Report lack of default value, default is mandatory
				return
			
		if "description" not in option:
			#TODO: Report lack of default description as a warning
			pass

		self._description = str(option["description"])
		self._default = str(option["default"])
		self._value = self._default

	def get_name (self):
		return self._name
	
	def get_description (self):
		return self._description
	
	def get_default (self):
		return self._default
	
	def get_value (self):
		return self._value
		
	def set_value (self, value):
		self._value = value
		
		
	def get_option_arguments (self):
		"WAF option arguments dictionary"
		return {"default": self.get_default (),
		        "action":  "store",
		        "help":    self.get_description ()}

#Mapping between tools and target classes
TOOL_CLASS_MAP = {'cc':   CcTarget,
                  'c++':  CcTarget,
                  'vala': ValaTarget,
                  'data': DataTarget}

# Mapping between file extensions and tools
EXT_TOOL_MAP = {'cc':   ('.c', '.h'),
		'c++':  ('.cpp', '.cxx'),
		'vala': ('.vala', '.gs')}

# Mapping used when multiple tools are fond (using file extensions)
# Keys must be sorted tuples
MULTI_TOOL_MAP = {('c++', 'cc'):  'c++',
		  ('cc', 'vala'): 'vala'}
