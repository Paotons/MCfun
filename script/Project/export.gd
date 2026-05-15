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
	if FileAccess.file_exists(path + ".zip"):
		DirAccess.remove_absolute(path + ".zip")
	
	var packer := ZIPPacker.new()
	packer.open(path + ".zip")
	
	_export_create_manifset(project, setting, packer)
	
	DirAccess.make_dir_absolute(path.path_join("functions"))
	_export_create_functions(project, setting, packer)
	
	packer.close()

# 创建主要文件。
static func _export_create_manifset(project : Project, setting : ProjectExportSetting, packer : ZIPPacker) -> void:
	setting.mutex.lock()
	setting.main_process = ProjectExportSetting.MainProcess.MANIFEST
	setting.current_process = "正在创建引导文件。"
	setting.sub_process = Vector2i(1, 1)
	setting.mutex.unlock()
	
	packer.start_file("manifest.json")
	var mainfest := create_manifest(project)
	packer.write_file(JSON.stringify(mainfest, "\t").to_utf8_buffer())
	packer.close_file()
# 创建函数。
static func _export_create_functions(project : Project, setting : ProjectExportSetting, packer : ZIPPacker) -> void:
	setting.mutex.lock()
	setting.main_process = ProjectExportSetting.MainProcess.FUNCTIONS
	setting.current_process = "正在解析函数"
	setting.sub_process = Vector2i(-1, -1)
	setting.mutex.unlock()
	
	var fun_paths := project.get_project_config().get_files_from_extension("mcfun")
	for i in fun_paths.size():
		var fun_path := fun_paths[i]
		
		setting.mutex.lock()
		setting.current_process = "正在解析函数[%s]" % [fun_path.get_file()]
		setting.sub_process =Vector2i(i, fun_paths.size())
		setting.mutex.unlock()
		
		_export_create_function(project, fun_path, packer)
# 创建函数。
static func _export_create_function(project : Project, fun_path : String, packer : ZIPPacker) -> void:
	var local := project.get_project_config().global_path_to_local(fun_path)
	
	var to_path := "functions".path_join(local.get_basename() + ".mcfunction")
	packer.start_file(to_path)
	packer.write_file(FileAccess.get_file_as_string(fun_path).to_utf8_buffer())
	packer.close_file()

## 创建一个 [code]manifest[/code] 内容。
static func create_manifest(project : Project) -> Dictionary:
	var config := project.get_project_config()
	var mainfest := {
	  "format_version": 2,
	  "header": {},
	  "modules": [],
	}
	mainfest.header = {
		"description": config.get_project_description(),
		"name": config.get_project_name(),
		"uuid": create_uuid(),
		"version": config.get_project_version(),
		"min_engine_version": config.get_project_main_engine_version(),
	  }
	mainfest.modules = [
		{
		  "type": "data",
		  "uuid": create_uuid(),
		  "version": config.get_project_version(),
		}
	  ]
	return mainfest

# 此函数由 DeepSeek 生成。
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

