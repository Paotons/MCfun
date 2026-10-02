@abstract
class_name BaseGrammarCompiler
extends Compiler
## 语法的解析器基类。
##
## 对于 Grammar 有关的解析器。抽象函数，你不应该实例化。

## 数据。
var compiler_data : GrammarCompilerData
# 文件替换者的模式。
const _FILE_REPLACED_MODES : PackedStringArray = ["replace", "expand"]
# 文件替换模式。
enum _FileReplacedMode {
	# 替换。
	REPLACE,
	# 扩展。
	EXPAND,
}

## 与指定解析器同步数据。
func compiler_sync(compiler : BaseGrammarCompiler) -> void:
	compiler_data = compiler.compiler_data

## 预编译阶段，用于将容器类数据，递归进行预编译操作，其中包括：[br][br]
## [code]{"type" : "file", "mode" : mode, "file" : path}[/code]，[param mode]默认为[b]replace[/b]会。
## 如果[param mode]为[b]replace[/b]，会使用[param path]文件下的数据替换该值。
## 如果[param mode]为[b]expand[/b]，会使用[param path]文件下的数据扩展该容器。
func pre_compile(box : Variant) -> void:
	if compiler_data == null:
		push_error("Unvalid compiler data.")
		return
	_precompile_file_replace(box)

# {"type" : "file", "mode" : mode, "file" : path}，mode默认为replace会。
# 如果mode为replace，会使用path文件下的数据替换该值。
# 如果mode为expand，会使用path文件下的数据扩展该容器。
func _precompile_file_replace(v : Variant) -> void:
	var boxes : Array = [v]
	
	while not boxes.is_empty():
		var box = boxes.pop_back()
		
		if box is Dictionary:
			for key in box:
				var value = box[key]
				if value is Array:
					boxes.append(value)
				if value is Dictionary:
					if _is_file_replaced(value):
						_file_replace_from_dict(box, key)
					else:
						boxes.append(value)
		
		if box is Array:
			for i in box.size():
				var value = box[i]
				if value is Array:
					boxes.append(value)
				if value is Dictionary:
					if _is_file_replaced(value):
						_file_replace_from_array(box, i)
					else:
						boxes.append(value)
# 对字典容器指定序列的文件替换进行文件替换操作。
func _file_replace_from_dict(box : Dictionary, key : Variant) -> void:
	var mode := _get_file_replaced_mode(box[key])
	var value = _get_file_replaced_value(box[key])
	
	if value is Array or value is Dictionary:
		pre_compile(value)
	
	match mode:
		_FileReplacedMode.REPLACE:
			box[key] = value
		_FileReplacedMode.EXPAND:
			if value is Dictionary:
				box.merge(value, true)
			else:
				box[key] = value
# 对数组容器指定序列的文件替换进行文件替换操作。
func _file_replace_from_array(box : Array, index : int) -> void:
	var mode := _get_file_replaced_mode(box[index])
	var value = _get_file_replaced_value(box[index])
	
	if value is Array or value is Dictionary:
		pre_compile(value)
	
	match mode:
		_FileReplacedMode.REPLACE:
			box[index] = value
		_FileReplacedMode.EXPAND:
			if value is Array:
				box.remove_at(index)
				box.append_array(value)
			else:
				box[index] = value
# 如果字典是允许的文件替换，返回 true。
func _is_file_replaced(dict : Dictionary) -> bool:
	var base_dir := compiler_data.base_directory
	if not (dict.has("type") and dict["type"] is String and dict["type"] == "file"):
		return false
	elif not (dict.has("file") and dict["file"] is String):
		return false
	var path : String = base_dir.path_join(dict["file"])
	if not FileAccess.file_exists(path):
		push_warning("Not find file \"%s\"." % path)
		return false
	if not _FILE_REPLACED_MODES.has(dict.get("mode", "replace")):
		return false
	return true
# 返回允许的文件替换，表示的变量。
func _get_file_replaced_value(dict : Dictionary) -> Variant:
	var path := compiler_data.base_directory.path_join(dict["file"])
	var value = JSON.parse_string(FileAccess.get_file_as_string(path))
	if value == null:
		push_warning("File \"%s\" has error json." % path)
	return value
# 返回允许的文件替换，表示的模式。
func _get_file_replaced_mode(dict : Dictionary) -> int:
	return _FILE_REPLACED_MODES.find(dict.get("mode", "replace"))
