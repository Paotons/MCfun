class_name ProjectConfig
extends Resource
## 项目配置文件。

# 项---项目。
const _SELECT_PROJECT := "Project"
# 项---编辑器。
const _SELECT_EDIT := "Edit"

# 项---项目的键。
const _SELECT_PROJECT_KEYS : PackedStringArray = ["name", "path", "nearest_time", "version"]
# 项---编辑器的键。
const _SELECT_EDIT_KEYS : PackedStringArray = ["grammar"]

## 项目配置文件路径。
const _CONFIG_PATH := ".project.cfg"
## 项目配置文件。
var _config : ConfigFile

#region 项目。
## 获取路径
func get_project_path() -> String:
	return _config.get_value(_SELECT_PROJECT, "path")
## 获取项目名称。
func get_project_name() -> String:
	return _config.get_value(_SELECT_PROJECT, "name")
## 获取项目最近时间。
func get_project_nearest_time() -> String:
	return (_config.get_value(_SELECT_PROJECT, "nearest_time") as String).replace("T", " ")
## 获取项目版本。
func get_project_version() -> PackedInt32Array:
	return _config.get_value(_SELECT_PROJECT, "version", [1, 0, 0])
## 获取最小游戏版本。
func get_project_main_engine_version() -> PackedInt32Array:
	return _config.get_value(_SELECT_PROJECT, "min_engine_varsion", [1, 20, 0])
## 获取项目描述。
func get_project_description() -> String:
	return _config.get_value(_SELECT_PROJECT, "description", "")

## 设置配置文件名称。
func set_project_name(value : String) -> void:
	_config.set_value(_SELECT_PROJECT, "name", value)
	_config.save(get_project_path().path_join(_CONFIG_PATH))
## 更新最近时间。
func update_project_nearest_time() -> void:
	_config.set_value(_SELECT_PROJECT, "nearest_time", Time.get_datetime_string_from_system())
	save()
## 获取项目版本。
func set_project_version(value : PackedInt32Array) -> void:
	_config.set_value(_SELECT_PROJECT, "version", value)
	save()
## 或者最小游戏版本。
func set_project_main_engine_version(value : PackedInt32Array) -> void:
	_config.set_value(_SELECT_PROJECT, "min_engine_version", value)
	save()
## 设置项目描述。
func set_project_description(value : String) -> void:
	_config.set_value(_SELECT_PROJECT, "description", value)
	save()
#endregion

#region 编辑器。
## 获取编辑器语法路径，如果 [param test] 为 [code]true[/code]，当目录不可用时会返回默认目录。
func get_edit_grammar_path(test := true) -> String:
	const DEFAULT := "res://resource/grammar/default"
	var path : String = _config.get_value(_SELECT_EDIT, "grammar", DEFAULT)
	return path if test and DirAccess.dir_exists_absolute(path) else DEFAULT
## 设置编辑器语法路径。
func set_edit_grammar_path(path : String) -> void:
	_config.set_value(_SELECT_EDIT, "grammar", path)
	save()
#endregion

## 保存。
func save() -> void:
	_config.save(get_project_path().path_join(_CONFIG_PATH))

## 获取项目所有的指定扩展名的文件。
func get_files_from_extension(extension : String) -> PackedStringArray:
	var path := get_project_path()
	var queue_directories : Array[DirAccess] = [DirAccess.open(path)]
	var result : PackedStringArray
	while not queue_directories.is_empty():
		var dir := queue_directories.pop_back() as DirAccess
		
		for child in dir.get_files():
			if child.get_extension() == extension:
				result.append(dir.get_current_dir().path_join(child))
		
		for child in dir.get_directories():
			queue_directories.append(DirAccess.open(dir.get_current_dir().path_join(child)))
	return result
## 获取局部路径。
func global_path_to_local(path : String) -> String:
	var p := get_project_path()
	return path.substr(p.length() + (0 if p.ends_with("/") else 1))

## 把版本转化成字符串。
static func version_to_string(varsion : PackedInt32Array) -> String:
	var texts : PackedStringArray
	for vas in varsion:
		texts.append(str(vas))
	return ".".join(texts)
## 把字符串转化成版本。
static func string_to_varsion(string : String) -> PackedInt32Array:
	var texts := string.split(".", false)
	var result : PackedInt32Array
	for text in texts:
		result.append(absi(int(text)))
	return result

## 返回指定目录下配置文件的路径。
static func get_config_path(path : String) -> String:
	return path.path_join(_CONFIG_PATH)

## [b]friend [ProjectManager]:[/b]设置项目配置文件。
func _set_config_file(file : ConfigFile) -> void:
	_config = file
## [b]friend [Project]:[/b]创建项目配置文件。
static func _create_config_file(name : String, path : String) -> ConfigFile:
	var config := ConfigFile.new()
	config.set_value(_SELECT_PROJECT, "name", name)
	config.set_value(_SELECT_PROJECT, "path", path)
	config.set_value(_SELECT_PROJECT, "nearest_time", Time.get_datetime_string_from_system())
	return config
## [b]friend [PronectManager]:[/b]打开指定目录下的配置文件。
static func _open_config_file(path : String) -> ProjectConfig:
	path = path.path_join(_CONFIG_PATH)
	if not FileAccess.file_exists(path):
		return null
	var file := ConfigFile.new()
	file.load(path)
	var config := ProjectConfig.new()
	config._set_config_file(file)
	return config
## [b]friend [Project]:[/b]将配置文件保存到指定目录下。
static func _save_config_file(config : ConfigFile, path : String) -> void:
	config.save(path.path_join(_CONFIG_PATH))
