class_name Grammer
extends Resource
## 语法。
##
## 支持不同版本。
## v1目录模式。[codeblock]
## {"files" : {"main_process" : false, "law" : false, "entry" : false}, "main" : false}
## [/codeblock]
class _Files extends Resource:
	var main_process : String
	var entry : String
	var law : String

class _Data extends Resource:
	# format_version 1
	# 数据格式 {0 : format_version, 1 : {0 : main_process, 1 : law, 2 : entry}
	var format_version : int
	var files : _Files
	
	func get_data() -> Dictionary:
		match format_version:
			0: return {0 : 0}
			1: return _get_data_v1()
			_: return {}
	
	func _get_data_v1() -> Dictionary:
		return {
			0 : format_version,
			1 : {0 : files.main_process, 1 : files.law, 2 : files.entry},
		}
	
	func set_data(data : Dictionary) -> PackedStringArray:
		var v = data.get(0, -1)
		format_version = v
		match v:
			0 : return []
			1 : return _set_data_v1(data)
			_ : return ["Unvaild format_version %d." % v]
	
	# NOTE 错误返回不具体。
	func _set_data_v1(data : Dictionary) -> PackedStringArray:
		if not data.has_all([1]):
			return ["Maind_data error."]
		elif not data[1] is Dictionary:
			return ["Maind_data error."]
		
		var files_ : Dictionary = data[1]
		if not files_.has_all([0, 1, 2]):
			return ["Maind_data error."]
		elif not (files_[0] is String and files_[1] is String and files_[2] is String):
			return ["Maind_data error."]
		
		files = _Files.new()
		files.main_process = data[1][0]
		files.law = data[1][1]
		files.entry = data[1][2]
		return []
# 数据。
var _data : _Data

## 目录路径。
var directory_path : String

## 主进程。
var main_process : GrammerProcess
## TODO 引擎进程。
var engine_process : GrammerProcess
## 账目。
var entry : GrammerEntry
## 规则。
var law : GrammerLaw

## 返回进程。
func get_process(idx := 0) -> GrammerProcess:
	return main_process if idx == 0 else null
## 返回账目。
func get_entry(idx := 0) -> GrammerEntry:
	return entry if idx == 0 else null
## 返回规则。
func get_law(idx := 0) -> GrammerLaw:
	return law if idx == 0 else null

func _clear() -> void:
	main_process = null
	law = null
	entry = null
	_data = null

#region 打开。
## 尝试打开，如果指定目录没有 [code].compiled[/code] 会解析该目录，再生成。
func try_open(path : String) -> PackedStringArray:
	var to_path := path.path_join(".compiled")
	
	if DirAccess.dir_exists_absolute(to_path):
		var errors := open(to_path)
		if errors.is_empty():
			return []
		else:
			_clear()
			return compile(path, to_path)
	else:
		DirAccess.make_dir_absolute(to_path)
		return compile(path, to_path)

# HACK 没有返回错误。
## 打开文件夹。
func open(path : String) -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(path):
		return ["Not find diractory \"%s\"." % path]
	elif not FileAccess.file_exists(path.path_join("main")):
		return ["Not find main file."]
	directory_path = path
	
	var data : Variant
	var errors : PackedStringArray
	
	var file := FileAccess.open(path.path_join("main"), FileAccess.READ)
	data = file.get_var()
	file.close()
	
	_data = _Data.new()
	errors = _data.set_data(data)
	if not errors.is_empty():
		return errors
	
	match _data.format_version:
		0 : return []
		1 : return _open_v1(path)
		_ : return ["Unvaild format_version %d." % _data.format_version]

@warning_ignore("unused_parameter")
func _open_v1(path : String) -> PackedStringArray:
	_data.files.main_process = path.path_join("files/main_process")
	_data.files.law = path.path_join("files/law")
	_data.files.entry = path.path_join("files/entry")
	
	if not FileAccess.file_exists(_data.files.main_process):
		return ["Not find main_process."]
	elif not FileAccess.file_exists(_data.files.law):
		return ["Not find law."]
	elif not FileAccess.file_exists(_data.files.entry):
		return ["Not find entry."]
	
	main_process = GrammerProcess.new()
	law = GrammerLaw.new()
	entry = GrammerEntry.new()
	
	var data : Variant
	var file : FileAccess
	
	file = FileAccess.open(_data.files.main_process, FileAccess.READ)
	data = file.get_var()
	file.close()
	main_process.set_data(data)
	
	file = FileAccess.open(_data.files.law, FileAccess.READ)
	data = file.get_var()
	file.close()
	law.set_data(data)
	
	file = FileAccess.open(_data.files.entry, FileAccess.READ)
	data = file.get_var()
	file.close()
	entry.set_data(data)
	return []
#endregion

## 解析，并把解析后的结果放入指定目录，返回错误信息。
func compile(path : String, to_path : String) -> PackedStringArray:
	directory_path = path
	
	if not DirAccess.dir_exists_absolute(path):
		return ["Not find directory."]
	
	if not DirAccess.dir_exists_absolute(to_path):
		return ["Not has target directory."]
	
	if not FileAccess.file_exists(path.path_join("main.json")):
		return ["Not find main.json file."]
	
	# 读取文件。
	var data = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("main.json")))
	if not data is Dictionary:
		return ["Main data must be dictionary."]
	var errors := _read_main(data)
	
	if not errors.is_empty():
		return errors
	
	_save_grammer(to_path)
	return []

#region 保存。
func _save_grammer(path : String) -> void:
	match  _data.format_version:
		0 : return
		1 : _save_grammer_v1(path)
		_ : push_error("Unkonw version.")

func _save_grammer_v1(path : String) -> void:
	var file : FileAccess
	
	file = FileAccess.open(path.path_join("main"), FileAccess.WRITE)
	file.store_var(_data.get_data())
	file.close()
	
	var files_dir := path.path_join("files")
	if not DirAccess.dir_exists_absolute(files_dir):
		DirAccess.make_dir_absolute(files_dir)
	
	file = FileAccess.open(files_dir.path_join("entry"), FileAccess.WRITE)
	file.store_var(entry.main_data)
	file.close()
	
	file = FileAccess.open(files_dir.path_join("law"), FileAccess.WRITE)
	file.store_var(law.main_data)
	file.close()
	
	file = FileAccess.open(files_dir.path_join("main_process"), FileAccess.WRITE)
	file.store_var(main_process.main_data)
	file.close()
#endregion

#region 读取 main。
# 主文件必须包含的数据。
const _MAIN_DATA_MUST_V1 := {
	"files" : {
		"process" : TYPE_STRING,
		"law" : TYPE_STRING,
		"entry" : TYPE_STRING,
	},
}
# 检查 main 文件必须要点。
func _test_main_musted(data : Dictionary, musted : Dictionary) -> PackedStringArray:
	var queue_dict : Array[Dictionary] = [data]
	var queue_must : Array[Dictionary] = [musted]
	var queue_path : Array[String] = ["Main_data"]
	var result : PackedStringArray
	while not queue_dict.is_empty():
		var dict := queue_dict.pop_back() as Dictionary
		var must := queue_must.pop_back() as Dictionary
		var path := queue_path.pop_back() as String
		
		for key in must.keys():
			var type = must[key]
			if not dict.has(key):
				result.append("%s not has %s." % [path, key])
			elif type is int and typeof(dict[key]) != type:
				result.append("%s[%s] should be %s." % [path, key, type_string(type)])
			elif type is Dictionary:
				if typeof(dict[key]) != TYPE_DICTIONARY:
					result.append("%s[%s] should be dictionary." % [path, key])
				else:
					queue_dict.append(dict[key])
					queue_must.append(must[key])
					queue_path.append(path + "[%s]" % key)
					continue
	return result

# 读取 main 文件。
func _read_main(data : Dictionary) -> PackedStringArray:
	if not data.has("format_version"):
		return ["Main_data not has format_version."]
	elif not data["format_version"] is float:
		return ["Main_data[format_version] should be int."]
	
	_data = _Data.new()
	_data.format_version = data["format_version"]
	
	var errors : PackedStringArray
	match _data.format_version:
		1: errors = _read_main_v1(data)
		_: return ["Main_data unvaild format_version %d." % _data.format_version]
	
	if not errors.is_empty():
		return errors
	
	return []

func _read_main_v1(data : Dictionary) -> PackedStringArray:
	var errors := _test_main_musted(data, _MAIN_DATA_MUST_V1)
	if not errors.is_empty():
		return errors
	
	var files := _Files.new()
	files.main_process = data["files"]["process"]
	files.entry = data["files"]["entry"]
	files.law = data["files"]["law"]
	
	errors = _set_grammer(files)
	if not errors.is_empty():
		return errors
	
	_data.files = files
	return []
#endregion

func _set_grammer(files : _Files) -> PackedStringArray:
	if not FileAccess.file_exists(directory_path.path_join(files.main_process)):
		return ["Not find main_process file."]
	elif not FileAccess.file_exists(directory_path.path_join(files.law)):
		return ["Not find law file."]
	elif not FileAccess.file_exists(directory_path.path_join(files.entry)):
		return  ["Not find entry file."]
	
	var obj : Compiler
	var data : Variant
	
	obj = GrammerEntryCompiler.new()
	data = JSON.parse_string(FileAccess.get_file_as_string(directory_path.path_join(files.entry)))
	obj.compile(data)
	if not obj.is_valid():
		return obj.errors
	entry = GrammerEntry.new()
	entry.set_data(obj.get_result())
	
	obj = GrammerLawCompiler.new()
	data = JSON.parse_string(FileAccess.get_file_as_string(directory_path.path_join(files.law)))
	obj.compile(data)
	if not obj.is_valid():
		return obj.errors
	law = GrammerLaw.new()
	law.set_data(obj.get_result())
	
	obj = GrammerProcessCompiler.new()
	data = JSON.parse_string(FileAccess.get_file_as_string(directory_path.path_join(files.main_process)))
	obj.compile(data)
	if not obj.is_valid():
		return obj.errors
	main_process = GrammerProcess.new()
	main_process.set_data(obj.get_result())
	
	return []


