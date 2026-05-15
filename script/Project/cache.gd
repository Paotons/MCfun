class_name ProjectChache
extends Resource
## 项目缓存。
##
## 目录模式。[codeblock]
## {".mcfun" : 
## 	{"grammer" : { "compiled" : {}, "name.txt" : false}
## }[/codeblock]

# 缓存目录。
const _CHACHE_DIRECTORY := ".mcfun"

## 目录。
var directory : String

# 返回缓存目录。
func _get_cache_directory() -> String:
	return directory.path_join(_CHACHE_DIRECTORY)

## 返回缓存语法目录。
func get_grammer_directory() -> String:
	return _get_cache_directory().path_join("grammer/compiled")

## [b]friend [Project]:[/b]加载缓存，需要在线程中运行。
func _load_cache(process : ProjectOpendProcess) -> void:
	if process != null:
		process.mutex.lock()
		process.main_name = "加载缓存。"
		process.main_process.x = ProjectOpendProcess.MainProcessName.CACHE
		process.sub_process = Vector2i(0, 1)
		process.mutex.unlock()
	
	var cache := _get_cache_directory()
	
	if not DirAccess.dir_exists_absolute(cache):
		DirAccess.make_dir_absolute(cache)
	
	_load_grammer(process)
func _load_grammer(process : ProjectOpendProcess) -> void:
	if process != null:
		process.mutex.lock()
		process.sub_process.x += 1
		process.mutex.unlock()
	
	var project := ProjectManager.get_current_project()
	var grammer := _get_cache_directory().path_join("grammer")
	
	if _test_grammer_name():
		var to_path := grammer.path_join("compiled")
		if DirAccess.dir_exists_absolute(to_path):
			FileSystem.remove_directory(to_path)
		DirAccess.make_dir_absolute(to_path)
		Grammer.new().compile(project.get_project_config().get_edit_grammer_path(), to_path)

# 如果语法改变，返回 true，并重新更新。
func _test_grammer_name() -> bool:
	var last_path := _get_cache_directory().path_join("grammer/name.txt")
	var last_name := FileAccess.get_file_as_string(last_path) if FileAccess.file_exists(last_path) else ""
	
	var path := ProjectManager.get_current_project().get_project_config().get_edit_grammer_path()
	assert(DirAccess.dir_exists_absolute(path), "Unvaild grammer")
	var name := path + "\n" + str(FileSystem.get_access_time(path))
	
	if last_name != name:
		var file := FileAccess.open(last_path, FileAccess.WRITE)
		file.store_string(name)
		file.close()
		return true
	return false

## [b]friend [Project]:[/b]初始化项目缓存。
static func _init_chache(path : String) -> void:
	DirAccess.make_dir_recursive_absolute(path.path_join(_CHACHE_DIRECTORY))

