@abstract
class_name GrammerCompiler
extends Compiler
## 语法的解析器。
##
## 对于 Grammer 有关的解析器。抽象函数，你不应该实例化。

## 数据。
var compiler_data : GrammerCompilerData

## 如果字典包含 [code]{"type" : "file", "file" : "path"}[/code] 的值，会从文件中读取 [code]json[/code] 替换该值。
static func dictionary_file_replace(dict : Dictionary, base_dir : String) -> void:
	for key in dict.keys():
		if not dict[key] is Dictionary:
			continue
		if not _is_replaced_file_dictionary(dict[key], base_dir):
			continue
		dict[key] = _get_replaced_file_dictionary_value(dict[key], base_dir)

static func _is_replaced_file_dictionary(dict : Dictionary, base_dir : String) -> bool:
	if not (dict.has("type") and dict["type"] is String and dict["type"] == "file"):
		return false
	elif not (dict.has("file") and dict["file"] is String):
		return false
	var path : String = base_dir.path_join(dict["file"])
	if not FileAccess.file_exists(path):
		push_warning("Not find file \"%s\"." % path)
		return false
	return true
static func _get_replaced_file_dictionary_value(dict : Dictionary, base_dir : String) -> Variant:
	var path := base_dir.path_join(dict["file"])
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	if value == null:
		push_warning("File \"%s\" has error json." % path)
	return value
