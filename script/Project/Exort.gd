class_name ProjectExport
extends Object
## 项目的导出。
##
## 静态类。

## 导出。
static func export(project : Project, setting : ProjectExportSetting) -> void:
	setting.mutex = Mutex.new()
	
	setting.mutex.lock()
	setting.main_process = ProjectExportSetting.MainProcess.START
	setting.current_process = "开始。"
	setting.sub_process = Vector2i(-1, -1)
	setting.mutex.unlock()
	
	var path := setting.path
	if DirAccess.dir_exists_absolute(path):
		FileSystem.remove_directory(path)
	
	DirAccess.make_dir_absolute(path)
	_export_create_manifset(project, setting)
	
	DirAccess.make_dir_absolute(path.path_join("functions"))
	_export_create_functions(project, setting)

# 创建主要文件。
static func _export_create_manifset(project : Project, setting : ProjectExportSetting) -> void:
	setting.mutex.lock()
	setting.main_process = ProjectExportSetting.MainProcess.MANIFEST
	setting.current_process = "正在创建引导文件。"
	setting.sub_process = Vector2i(1, 1)
	setting.mutex.unlock()
	
	var path := setting.path
	var mainfest := create_manifest(project)
	var file := FileAccess.open(path.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(mainfest, "\t"))
# 创建函数。
static func _export_create_functions(project : Project, setting : ProjectExportSetting) -> void:
	setting.mutex.lock()
	setting.main_process = ProjectExportSetting.MainProcess.FUNCTIONS
	setting.current_process = "正在解析函数"
	setting.sub_process = Vector2i(-1, -1)
	setting.mutex.unlock()
	
	var funs_path := setting.path.path_join("functions")
	
	var fun_paths := project.get_files_from_extension("mcfun")
	for i in fun_paths.size():
		var fun_path := fun_paths[i]
		
		setting.mutex.lock()
		setting.current_process = "正在解析函数[%s]" % [fun_path.get_file()]
		setting.sub_process =Vector2i(i, fun_paths.size())
		setting.mutex.unlock()
		
		_export_create_function(project, fun_path, funs_path)
# 创建函数。
static func _export_create_function(project : Project, fun_path : String, funs_path : String) -> void:
	var local := project.global_path_to_local(fun_path)
	
	var to_path := funs_path.path_join(local.get_basename() + ".mcfunction")
	if not DirAccess.dir_exists_absolute(to_path.get_base_dir()):
		var dir := DirAccess.open(funs_path)
		dir.make_dir_recursive(to_path.get_base_dir())
	
	var file := FileAccess.open(to_path, FileAccess.WRITE)
	file.store_string(FileAccess.get_file_as_string(fun_path))
	file.close()

## 创建一个 [code]manifest[/code] 内容。
static func create_manifest(project : Project) -> Dictionary:
	var mainfest := {
	  "format_version": 2,
	  "header": {},
	  "modules": [],
	}
	mainfest.header = {
		"description": "没有描述",
		"name": project.get_project_name(),
		"uuid": create_uuid(),
		"version": [1, 0, 0],
		"min_engine_version": [1, 20, 0]
	  }
	mainfest.modules = [
		{
		  "type": "data",
		  "uuid": create_uuid(),
		  "version": [1, 0, 0]
		}
	  ]
	return mainfest

## 生成一个 uuid。
static func create_uuid() -> String:
	const HEX := "0123456789abcdef"
	var parts := PackedStringArray()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var part1 := ""
	for i in range(8):
		part1 += HEX[rng.randi() % 16]
	parts.append(part1)
	
	var part2 := ""
	for i in range(4):
		part2 += HEX[rng.randi() % 16]
	parts.append(part2)
	
	var part3 := "4"
	for i in range(3):
		part3 += HEX[rng.randi() % 16]
	parts.append(part3)
	
	var variant_options := PackedStringArray(["8", "9", "a", "b"])
	var part4 := variant_options[rng.randi() % 4]
	for i in range(3):
		part4 += HEX[rng.randi() % 16]
	parts.append(part4)
	
	var part5 := ""
	for i in range(12):
		part5 += HEX[rng.randi() % 16]
	parts.append(part5)
	
	return "-".join(parts)


