class_name Project
extends Resource
## 项目。

## 项目配置。
var project_config : ProjectConfig
## 项目缓存。
var project_cache : ProjectChache

## 用于初始化，项目被打开，需要在线程里运行。
func _opend(process : ProjectOpendProcess) -> void:
	if process != null:
		process.main_process.y = ProjectOpendProcess.MainProcessName.MAX
	
	project_cache._load_cache(process)

## 获取项目配置。
func get_project_config() -> ProjectConfig:
	return project_config
## 获取项目缓存。
func get_project_cache() -> ProjectChache:
	return project_cache

## [b]friend [ProjectManager]:[/b] 创建项目。
func _create_project(name : String) -> void:
	var path := ProjectManager.get_project_path(name)
	project_config = ProjectManager._get_project_config_file(name)
	project_cache = ProjectChache.new()
	project_cache.directory = path

## [b]friend [ProjectManager]:[/b] 初始化项目文件。
static func _init_project_file(path : String, name : String) -> void:
	var config := ProjectConfig._create_config_file(name, path)
	ProjectConfig._save_config_file(config, path)
	
	ProjectChache._init_chache(path)
