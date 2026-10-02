class_name GrammarCompilerData
extends Resource
## 解析语法的数据。
##
##

## 基目录。
var base_directory : String
## 主文件。
var main_file := GrammarMain.new()

## 语法进程数据。
var grammar_process_data : Dictionary
## 语法规则数据。
var grammar_law_data : Dictionary
## 语法章类数据。
var grammar_entry_data : Dictionary

## 加路径。
func path_join(path : String) -> String:
	return base_directory.path_join(path)
## 返回文件路径。
func get_file_path(type : GrammarMain.FileType) -> String:
	var p := main_file.get_file_path(type)
	return base_directory.path_join(p) if not p.is_empty() else ""
