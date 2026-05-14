class_name Grammer
extends Resource
## 语法。

class _Files extends Resource:
	var main_process : String
	var entry : String
	var law : String

class _Data extends Resource:
	var format_version : int
	var files : _Files
# 数据。
var _data : _Data

## 目录路径。
var directory_path : String

## 主进程。
var main_process : GrammerProcess
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

## 打开文件。
func open(path : String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		directory_path = ""
		return
	
	directory_path = path
	

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
	
	return []


const _MAIN_DATA_MUST := {
	"files" : {
		"process" : TYPE_STRING,
		"law" : TYPE_STRING,
		"entry" : TYPE_STRING,
	},
}
# 检查 main 文件必须要点。
func _test_main_musted(data : Dictionary) -> PackedStringArray:
	var queue_dict : Array[Dictionary] = [data]
	var queue_must : Array[Dictionary] = [_MAIN_DATA_MUST]
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
	var errors := _test_main_musted(data)
	if not errors.is_empty():
		return errors
	
	var files := _Files.new()
	files.main_process = data["files"]["main_process"]
	files.entry = data["files"]["entry"]
	files.law = data["files"]["law"]
	
	if not FileAccess.file_exists(directory_path.path_join(files.main_process)):
		return ["Not find main_process file."]
	elif not FileAccess.file_exists(directory_path.path_join(files.law)):
		return ["Not find law file."]
	elif not FileAccess.file_exists(directory_path.path_join(files.entry)):
		return  ["Not find entry file."]
	
	var obj : Compiler
	obj = GrammerProcessCompiler.new()
	obj.compile(FileAccess.get_file_as_string(directory_path.path_join(files.main_process)))
	
	
	_data.files = files
	return []


