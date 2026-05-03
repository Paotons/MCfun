extends Node
## 文件系统。
##
## 全局单例。

## 如果为 [code]true[/code]，则使用的是测试路径。
const IS_TEST_PATH := false

## 用户的根目录。
var user_root : String
## 数据的根目录。
var data_root : String

## 缓存目录。
var cache_path : String

## 配置文件目录。
var config_path : String
## 配置文件。
var config : ConfigFile


func _init() -> void:
	OS.request_permissions()
	if IS_TEST_PATH:
		user_root = "res://test/user_root"
		data_root = "res://test/data_root"
	else:
		user_root = "user://"
		if OS.get_name() == "Android":
			data_root = "/storage/emulated/0/Android/data/com.paotons.mcfun/files"
		else:
			data_root = "user://data"
			DirAccess.make_dir_absolute(data_root)

func _ready() -> void:
	user_root = ProjectSettings.globalize_path(user_root)
	data_root = ProjectSettings.globalize_path(data_root)
	if not (DirAccess.dir_exists_absolute(user_root) and DirAccess.dir_exists_absolute(data_root)):
		OS.alert("Not find main path.", "Error")
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
	
	cache_path = user_root.path_join("cache")
	if DirAccess.dir_exists_absolute(cache_path):
		clear_cache()
	DirAccess.make_dir_absolute(cache_path)
	
	config_path = user_root.path_join("config.cfg")
	if FileAccess.file_exists(config_path):
		DirAccess.copy_absolute(config_path, cache_path.path_join("config.cfg"))
		config = ConfigFile.new()
		config.load(cache_path.path_join("config.cfg"))
		
		get_window().content_scale_factor = config.get_value("UINormal", "window_scale_factor", 1.0)

func _exit_tree() -> void:
	clear_cache()

## 递归删除文件夹。
func remove_directory(path : String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		push_error("Not find directory.")
		return
	
	var queue_directories : Array[DirAccess] = [DirAccess.open(path)]
	var queue_parents : Array[DirAccess] = [DirAccess.open(path.get_base_dir())]
	while not queue_directories.is_empty():
		var directory := queue_directories.back() as DirAccess
		
		var subdirectories := directory.get_directories()
		if not subdirectories.is_empty():
			for child in subdirectories:
				queue_directories.append(DirAccess.open(directory.get_current_dir().path_join(child)))
				queue_parents.append(directory)
			continue
		
		for child in directory.get_files():
			directory.remove(child)
		
		var parent := queue_parents.pop_back() as DirAccess
		parent.remove(directory.get_current_dir().get_file())
		queue_directories.remove_at(queue_directories.size() - 1)

## 清理缓存。
func clear_cache() -> void:
	var queue_dirs : PackedStringArray = [cache_path]
	var empty_dirs : PackedStringArray
	while not queue_dirs.is_empty():
		var dir := queue_dirs[queue_dirs.size() - 1]
		queue_dirs.remove_at(queue_dirs.size() - 1)
		for file in DirAccess.get_files_at(dir):
			DirAccess.remove_absolute(file)
		for direct in DirAccess.get_directories_at(dir):
			queue_dirs.append(dir.path_join(direct))
		empty_dirs.append(dir)
	for dir in empty_dirs: DirAccess.remove_absolute(dir)

