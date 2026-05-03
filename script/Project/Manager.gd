extends Node
## 项目管理。
##
## 全局单例。

## 默认项目列表。
var project_list_path := "storage/projects"
## 项目列表的配置文件。
var project_list_config_path := "project_list.cfg"
## 项目列表配置文件。
var project_list_config := ConfigFile.new()

## 当前使用的项目。
var current_project : Project

## 获取项目配置文件。
func _ready() -> void:
	project_list_path = FileSystem.data_root.path_join(project_list_path)
	if not DirAccess.dir_exists_absolute(project_list_path):
		var root := DirAccess.open(FileSystem.data_root)
		root.make_dir_recursive(project_list_path)
	project_list_config_path = FileSystem.user_root.path_join(project_list_config_path)
	if FileAccess.file_exists(project_list_config_path):
		project_list_config.load(project_list_config_path)

## 如果当前正在项目编辑，返回 [code]true[/code]。
func is_edit_project() -> bool:
	return current_project != null
## 获取当前项目。
func get_current_project() -> Project:
	return current_project

@warning_ignore("shadowed_variable_base_class")
## 获取项目。
func get_project(name : String) -> Project:
	var project := Project.new()
	project.config = get_project_config(name)
	return project
## 获取项目数量。
func get_project_count() -> int:
	return 0 if not project_list_config.has_section("List") else project_list_config.get_section_keys("List").size()
## 获取所有项目名称。
func get_project_names() -> PackedStringArray:
	return PackedStringArray() if not project_list_config.has_section("List") else project_list_config.get_section_keys("List")
@warning_ignore("shadowed_variable_base_class")
## 获取项目的目录。
func get_project_path(name : String) -> String:
	return project_list_config.get_value("List", name)
@warning_ignore("shadowed_variable_base_class")
## 获取项目配置文件。
func get_project_config(name : String) -> ConfigFile:
	var path := get_project_path(name).path_join(Project.PROJECT_CONFIG_PATH)
	if not FileAccess.file_exists(path):
		return null
	var config := ConfigFile.new()
	config.load(path)
	return config
@warning_ignore("shadowed_variable_base_class")
## 如果有这个项目，返回 [code]true[/code]。
func has_project(name : String) -> bool:
	if not project_list_config.has_section("List"):
		return false
	return project_list_config.has_section_key("List", name)
## 新增项目。
@warning_ignore("shadowed_variable_base_class")
func add_project_list(name : String, path : String) -> void:
	project_list_config.set_value("List", name, path)
	project_list_config.save(project_list_config_path)

@warning_ignore("shadowed_variable_base_class")
## 移除项目。
func remove_project_list(name : String) -> void:
	if project_list_config == null:
		return
	elif not project_list_config.has_section("List"):
		return
	elif not project_list_config.has_section_key("List", name):
		return
	project_list_config.erase_section_key("List", name)
	project_list_config.save(project_list_config_path)
@warning_ignore("shadowed_variable_base_class")
## 创建项目。
func create_project(name : String, path : String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		return false
	var config := _create_config_file(name, path)
	config.save(path.path_join(Project.PROJECT_CONFIG_PATH))
	add_project_list(name, path)
	return true

@warning_ignore("shadowed_variable_base_class")
# 创建配置文件。
func _create_config_file(name : String, path : String) -> ConfigFile:
	var config := ConfigFile.new()
	config.set_value(Project.CONFIG_SELECT_PROJECT, "name", name)
	config.set_value(Project.CONFIG_SELECT_PROJECT, "path", path)
	config.set_value(Project.CONFIG_SELECT_PROJECT, "nearest_time", Time.get_datetime_string_from_system())
	return config
