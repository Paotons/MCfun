class_name ElementCMDCompiler
extends GrammarCompiler
## 元素命令解析器。

## 元素名称。
var element_name : String

class CMD extends GrammarCompiler:
	enum Head {
		## 列表。
		LIST,
		## 补全
		COMPLETION,
		## 最大。
		MAX,
	}

class _List extends CMD:
	static var list_regex := RegEx.create_from_string(r"^ *list +(?<list_name>\w+) +add +self *$")
	
	enum ListMode {
		# 添加
		ADD,
	}
	
	func _compile(data : Variant) -> void:
		var from : String = data
		var result := list_regex.search(from)
		if result == null:
			return
		
		compiled_result = [Head.LIST, ListMode.ADD, result.get_string("list_name")]
		_set_is_valid(true)

class _Completion extends CMD:
	static var compiler_regex := RegEx.create_from_string(r"^ *completion +list +(?<list_name>\w+) *$")
	
	enum CompletionMode {
		# 列表
		LIST,
	}
	
	func _compile(data : Variant) -> void:
		var from : String = data
		var result := compiler_regex.search(from)
		if result == null:
			return
		
		compiled_result = [Head.COMPLETION, CompletionMode.LIST, result.get_string("list_name")]
		_set_is_valid(true)

## 解析。
func _compile(data : Variant) -> void:
	if not _test_value_type(data, 1 << TYPE_ARRAY, "%s[cmd]" % element_name):
		return
	if not _test_array_types(data, 1 << TYPE_STRING, "%s[cmd]" % element_name):
		return
	
	var from := PackedStringArray(data)
	compiled_result = []
	
	for i in from.size():
		var string := from[i]
		if not _compile_string(string):
			return
	_set_is_valid(true)

func _compile_string(string : String) -> bool:
	var obj : CMD
	for i in CMD.Head.MAX:
		match i:
			CMD.Head.LIST: obj = _List.new()
			CMD.Head.COMPLETION: obj = _Completion.new()
		
		obj.compile(string)
		if not obj.is_valid():
			continue
		(compiled_result as Array).append(obj.get_result())
		return true
	errors.append("%s not has cmd \"%s\"." % [element_name, string])
	return false



