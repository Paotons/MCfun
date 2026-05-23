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
	_init_main_root()

## 如果成功初始化，返回 [code]true[/code]。
func is_initialed() -> bool:
	return _is_initial_finished

#region 初始化。
# 初始化主要路径。
func _init_main_root() -> void:
	user_root = "res://test/user_root" if OS.has_feature("editor") else "user://"
	
	data_root = get_data_root_path()
	if data_root.is_empty():
		await get_tree().process_frame # 等待场景加载结束
		var window := select_data_root()
		await window.close_requested
		data_root = get_data_root_path()
	
	if data_root.is_empty():
		data_root = user_root.path_join("data")
		DirAccess.make_dir_absolute(data_root)
	
	_init_main_directory()
	_is_initial_finished = true
	initial_finished.emit()

# 初始化主要目录。
func _init_main_directory() -> void:
	user_root = ProjectSettings.globalize_path(user_root)
	data_root = ProjectSettings.globalize_path(data_root)
	if not (DirAccess.dir_exists_absolute(user_root) and DirAccess.dir_exists_absolute(data_root)):
		OS.alert("Not find main path.", "Error")
		await get_tree().create_timer(1.0).timeout
		get_tree().quit()
	
	_init_cache_directory()
	_init_config_file()
	_init_grammar_directory()
# 初始化缓存目录。
func _init_cache_directory() -> void:
	cache_path = user_root.path_join("cache")
	if DirAccess.dir_exists_absolute(cache_path):
		clear_cache()
	DirAccess.make_dir_absolute(cache_path)
# 初始化配置文件目录。
func _init_config_file() -> void:
	config_path = user_root.path_join("config.cfg")
	if FileAccess.file_exists(config_path):
		DirAccess.copy_absolute(config_path, cache_path.path_join("config.cfg"))
		config = ConfigFile.new()
		config.load(cache_path.path_join("config.cfg"))
		
		get_window().content_scale_factor = config.get_value("UINormal", "window_scale_factor", 1.0)
# 初始化语法目录。
func _init_grammar_directory() -> void:
	if not is_initialed():
		await initial_finished
	const GRAMMER_PATH := "res://resource/grammar/"
	var path := data_root.path_join("storage/grammar")
	if not DirAccess.dir_exists_absolute(path):
		copy_directory(GRAMMER_PATH, path)
	
	if OS.has_feature("editor"):
		_init_grammar_native_process()
# 初始化本地流程目录。
func _init_grammar_native_process() -> void:
	const PATH := "res://resource/native/process.json"
	const COMPILED := "res://resource/native/compiled/process"
	
	if FileAccess.file_exists(COMPILED):
		return
	var data : Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	
	var process := GrammarProcessCompiler.new()
	process.compile(data)
	
	assert(process.is_valid(), "Native is unvaild.")
	
	if not DirAccess.dir_exists_absolute(COMPILED.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(COMPILED.get_base_dir())
	
	var file := FileAccess.open(COMPILED, FileAccess.WRITE)
	file.store_var(process.get_result())
	file.close()

#endregion

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

## 递归删除目录。
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
## 递归复制目录。
func copy_directory(from : String, to : String, chmod_flags := -1) -> void:
	if FileAccess.file_exists(from):
		DirAccess.copy_absolute(from, to, chmod_flags)
		return
	
	if not DirAccess.dir_exists_absolute(from):
		return
	
	if not DirAccess.dir_exists_absolute(to):
		DirAccess.make_dir_recursive_absolute(to)
	
	var queue_directories : Array[DirAccess] = [DirAccess.open(from)]
	var queue_to_directories : Array[DirAccess] = [DirAccess.open(to)]
	while not queue_directories.is_empty():
		var directory : DirAccess = queue_directories.pop_back()
		var to_directory : DirAccess = queue_to_directories.pop_back()
		
		for file in directory.get_files():
			var data := FileAccess.get_file_as_bytes(directory.get_current_dir().path_join(file))
			var f := FileAccess.open(to_directory.get_current_dir().path_join(file), FileAccess.WRITE)
			f.store_buffer(data)
			f.close()
		
		for dir in directory.get_directories():
			if not to_directory.dir_exists(dir):
				to_directory.make_dir(dir)
			queue_directories.append(DirAccess.open(directory.get_current_dir().path_join(dir)))
			queue_to_directories.append(DirAccess.open(to_directory.get_current_dir().path_join(dir)))
## 返回修改时间戳。
func get_access_time(path : String) -> int:
	if FileAccess.file_exists(path):
		return FileAccess.get_access_time(path)
	if not DirAccess.dir_exists_absolute(path):
		return 0
	
	var time := 0
	var queue_directories : Array[DirAccess] = [DirAccess.open(path)]
	while not queue_directories.is_empty():
		var directory : DirAccess = queue_directories.pop_back()
		
		for file in directory.get_files():
			time = maxi(time, FileAccess.get_access_time(directory.get_current_dir().path_join(file)))
		
		for dir in directory.get_directories():
			queue_directories.append(DirAccess.open(directory.get_current_dir().path_join(dir)))
	return time
## 返回指定目录下指定扩展名的文件，没有返回所有文件。
func get_directory_files(path : String, extensions : PackedStringArray = [], clip := true) -> PackedStringArray:
	if FileAccess.file_exists(path):
		return PackedStringArray([path]) if extensions.is_empty() or extensions.has(path.get_extension()) else PackedStringArray()
	if not DirAccess.dir_exists_absolute(path):
		return PackedStringArray()
	
	var start := path.length() + (1 if not path.ends_with("/") else 0) if clip else 0
	var result : PackedStringArray
	var queue_directories : Array[DirAccess] = [DirAccess.open(path)]
	while not queue_directories.is_empty():
		var directory : DirAccess = queue_directories.pop_back()
		var dpath := directory.get_current_dir()
		
		for file in directory.get_files():
			if extensions.is_empty() or extensions.has(file.get_extension()):
				result.append(dpath.path_join(file).substr(start))
		
		for dir in directory.get_directories():
			queue_directories.append(DirAccess.open(dpath.path_join(dir)))
	return result

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

