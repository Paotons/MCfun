class_name Project
extends Resource
## 项目。

## 配置文件项目的项。
const CONFIG_SELECT_PROJECT := "Project"
## 配置文件的键。
const CONFIG_SELECT_PROJECT_KEYS : PackedStringArray = ["name", "path", "nearest_time", "version"]
## 项目配置文件。
const PROJECT_CONFIG_PATH := ".project.cfg"

var config : ConfigFile

## 获取路径
func get_project_path() -> String:
	return config.get_value(CONFIG_SELECT_PROJECT, "path")
## 获取项目名称。
func get_project_name() -> String:
	return config.get_value(CONFIG_SELECT_PROJECT, "name")
## 获取项目最近时间。
func get_project_nearest_time() -> String:
	return (config.get_value(CONFIG_SELECT_PROJECT, "nearest_time") as String).replace("T", " ")
## 获取项目版本。
func get_project_version() -> PackedInt32Array:
	return config.get_value(CONFIG_SELECT_PROJECT, "version", [1, 0, 0])
## 获取最小游戏版本。
func get_project_main_engine_version() -> PackedInt32Array:
	return config.get_value(CONFIG_SELECT_PROJECT, "min_engine_varsion", [1, 2, 0])
## 获取项目描述。
func get_project_description() -> String:
	return config.get_value(CONFIG_SELECT_PROJECT, "description", "")

## 设置配置文件名称。
func set_project_name(value : String) -> void:
	config.set_value(CONFIG_SELECT_PROJECT, "name", value)
	config.save(get_project_path().path_join(PROJECT_CONFIG_PATH))
## 更新最近时间。
func update_project_nearest_time() -> void:
	config.set_value(CONFIG_SELECT_PROJECT, "nearest_time", Time.get_datetime_string_from_system())
	save()
## 获取项目版本。
func set_project_version(value : PackedInt32Array) -> void:
	config.set_value(CONFIG_SELECT_PROJECT, "version", value)
	save()
## 或者最小游戏版本。
func set_project_main_engine_version(value : PackedInt32Array) -> void:
	config.set_value(CONFIG_SELECT_PROJECT, "min_engine_version", value)
	save()
## 设置项目描述。
func set_project_description(value : String) -> void:
	config.set_value(CONFIG_SELECT_PROJECT, "description", value)
	save()

## 保存。
func save() -> void:
	config.save(get_project_path().path_join(PROJECT_CONFIG_PATH))

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


