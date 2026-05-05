extends Node
## 文件系统。
##
## 全局单例。

## 初始化成功时发出。
signal initial_finished

# 如果初始化过，则是 [code]true[/code]。
var _is_initial_finished := false

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

func _ready() -> void:
	_initial_main_root()

## 如果成功初始化，返回 [code]true[/code]。
func is_initialed() -> bool:
	return _is_initial_finished

# 初始化主要路径。
func _initial_main_root() -> void:
	user_root = "res://test/user_root" if OS.has_feature("editor") else "user://"
	
	data_root = get_data_root_path()
	if data_root.is_empty():
		await get_tree().process_frame
		var window := select_data_root()
		await window.close_requested
		data_root = get_data_root_path()
	
	if data_root.is_empty():
		data_root = user_root.path_join("data")
		DirAccess.make_dir_absolute(data_root)
	
	_initial_main_directory()
	_is_initial_finished = true
	initial_finished.emit()

# 初始化主要目录。
func _initial_main_directory() -> void:
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

## 选择数据目录。
func select_data_root() -> SelectedDataRootWindow:
	const packed := preload("uid://cj6k3ve1jedrn") as PackedScene
	var window := packed.instantiate() as SelectedDataRootWindow
	get_viewport().get_window().add_child(window)
	window.popup_centered_clamped()
	return window

## 获取数据目录引导文件内容。
func get_data_root_path() -> String:
	var data_root_file_path := user_root.path_join("data_root_path")
	if not FileAccess.file_exists(data_root_file_path):
		return ""
	else:
		return FileAccess.get_file_as_string(data_root_file_path)
## 修改数据目录引导文件。
func set_data_root_path(path : String) -> void:
	var data_root_file_path := user_root.path_join("data_root_path")
	var file := FileAccess.open(data_root_file_path, FileAccess.WRITE)
	file.store_string(path)
	file.close()

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

