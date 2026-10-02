class_name GrammarMain
extends Resource
## 语法的主文件数据。
##
##
# format_version 1
# 数据格式 {0 : format_version, 1 : {0 : main_process, 1 : law, 2 : entry}

## 必要的文件类型。
const ESSENT_FILE_TYPES := [FileType.MAIN_PROCESS, FileType.LAW, FileType.ENTRY]
## 所有文件类型。
const ALL_FILE_TYPES := [FileType.MAIN_PROCESS, FileType.LAW, FileType.ENTRY, FileType.TRANSLATION]

## 文件类型。
enum FileType {
	## 主进程。
	MAIN_PROCESS = 0,
	## 规则。
	LAW = 1,
	## 章类。
	ENTRY = 2,
	## 翻译。
	TRANSLATION = 3,
}

class _Files extends Resource:
	var main_process : String
	var law : String
	var entry : String
	var translation : String
	
	func get_file_path(type : FileType) -> String:
		match type:
			FileType.MAIN_PROCESS:
				return main_process
			FileType.LAW:
				return law
			FileType.ENTRY:
				return entry
			FileType.TRANSLATION:
				return translation
			_:
				return ""
	func set_file_path(type : FileType, value : String) -> void:
		match type:
			FileType.MAIN_PROCESS:
				main_process = value
			FileType.LAW:
				law = value
			FileType.ENTRY:
				entry = value
			FileType.TRANSLATION:
				translation = value
	func get_file_data() -> Dictionary:
		return {FileType.MAIN_PROCESS : main_process, FileType.LAW : law, FileType.ENTRY : entry, FileType.TRANSLATION : translation}
	func set_file_data(data : Dictionary) -> void:
		main_process = data.get(FileType.MAIN_PROCESS, "")
		law = data.get(FileType.LAW, "")
		entry = data.get(FileType.ENTRY, "")
		translation = data.get(FileType.TRANSLATION, "")

## 版本号。
var format_version : int
## 文件。
var _files := _Files.new()

## 返回数据。
func get_data() -> Dictionary:
	match format_version:
		0: return {0 : 0}
		1: return _get_data_v1()
		_: return {}
## 设置数据。
func set_data(data : Dictionary) -> PackedStringArray:
	var v = data.get(0, -1)
	format_version = v
	match v:
		0 : return []
		1 : return _set_data_v1(data)
		_ : return ["Unvaild format_version %d." % v]

## 返回文件路径。
func get_file_path(type : FileType) -> String:
	return _files.get_file_path(type)
## 设置文件路径。
func set_file_path(type : FileType, path : String) -> void:
	_files.set_file_path(type, path)

func _get_data_v1() -> Dictionary:
	return {
		0 : format_version,
		1 : _files.get_file_data(),
	}
# NOTE 错误返回不具体。
func _set_data_v1(data : Dictionary) -> PackedStringArray:
	if not data.has_all([1]):
		return ["Maind_data error."]
	elif not data[1] is Dictionary:
		return ["Maind_data error."]
	
	var files : Dictionary = data[1]
	if not files.has_all(ESSENT_FILE_TYPES):
		return ["Maind_data error."]
	
	for type in ALL_FILE_TYPES:
		if files.has(type) and not files[type] is String:
			return ["Maind_data error."]
	
	_files = _Files.new()
	_files.set_file_data(files)
	return []
