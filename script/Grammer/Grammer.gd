class_name Grammer
extends Resource
## 语法。

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
	pass

## 解析，并把解析后的结果放入指定目录，返回错误信息。
func compile(path : String, to_path : String) -> String:
	if not DirAccess.dir_exists_absolute(path):
		return "Not find directory."
	if not DirAccess.dir_exists_absolute(to_path):
		DirAccess.make_dir_recursive_absolute(to_path)
	
	
	
	return ""



