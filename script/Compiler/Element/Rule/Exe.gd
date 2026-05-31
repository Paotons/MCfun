class_name ExeElementRuleCompiler
extends Compiler
## 解析可执行元素规则的解析器。

## 列表类型。
var cmd_list_types : PackedStringArray

class _Element extends Compiler:
	#region 元素。
	## ID，对应 id。
	const META_ID := 10
	## 继承，-1 表示继承最开头， -2 继承所有。
	const META_EXTENDS := 11
	## 可结束。
	const META_IS_END := 12
	## 跳转。
	const META_GOTO := 13
	#endregion
	
	var element : String
	var command : Array
	
	static var _next_id := 0xFFFFFF
	
	# 生成一个 ID。
	static func rand_id() -> int:
		_next_id += 1
		return _next_id
	
	# 获取指令选项的 ID 条目的序列。
	func id_to_index(id : int) -> int:
		for i in command.size():
			var param : Dictionary = command[i]
			if not param.has("id"):
				continue
			elif param["id"] == id:
				return i
		return -1
	
	# 默认解析 extends。
	func compile_extends_default(from : Dictionary) -> bool:
		if not from.has("extends"):
			compiled_result[META_EXTENDS] = -2
			return true
		elif not _try_dictionary_key(from, "%s[extends]" % element, "extends", META_EXTENDS, true,
			_test_value_type.bind(1 << TYPE_INT | 1 << TYPE_FLOAT, "%s[extends]" % element),
		):
			return false
		return true
	# 默认解析 id。
	func compile_id_default(from : Dictionary) -> bool:
		if not from.has("id"):
			compiled_result[META_ID] = rand_id()
			return true
		elif not _try_dictionary_key(from, "%s[id]" % element, "id", META_ID, true,
			_test_value_type.bind(1 << TYPE_INT | 1 << TYPE_FLOAT, "%s[id]" % element)
		):
			return false
		return true
	# 默认解析 is_end。
	func compile_is_end_default(from : Dictionary) -> bool:
		return _try_dictionary_key(from, "%s[is_end]" % element, "is_end", META_IS_END, false,
			_test_value_type.bind(1 << TYPE_BOOL, "%s[is_end]" % element)
		)
	# 默认解析 goto。
	func compile_goto_default(from : Dictionary) -> bool:
		if from.has("goto"):
			if not _test_value_type(from["goto"], 1 << TYPE_INT | 1 << TYPE_FLOAT, "%s[goto]" % element):
				return false
			var goto := from["goto"] as int
			var goto_i := id_to_index(goto)
			if goto_i == -1:
				errors.append("%s[goto] is %d, but not has the id." % [element, goto])
				return false
			compiled_result[META_GOTO] = goto_i
			return true
		else:
			return true

class _Option extends _Element:
	## 元素物体。
	const META_ITEMS := 2
	const _ITEMS_ITEMS := 0
	
	func _compile(data : Variant) -> void:
		var form := data as Dictionary
		
		if not (
			compile_extends_default(form) and 
			compile_id_default(form) and
			compile_is_end_default(form)
		):
			return
		
		var size := (compiled_result[META_ITEMS][_ITEMS_ITEMS] as Array).size()
		if form.has("goto"):
			if not _test_value_array_types(form["goto"], 1 << TYPE_INT | 1 << TYPE_FLOAT, "%s[goto]" % element, size):
				return
			
			var result : PackedInt32Array
			for i in form["goto"].size():
				var goto := form["goto"][i] as int
				var goto_i := id_to_index(goto)
				if goto_i == -1:
					errors.append("%s[goto][%d] is %d, but not has the id." % [element, i, goto])
					return
				result.append(goto_i)
			compiled_result[META_GOTO] = result
		_set_is_valid(true)

class _Nil extends _Element:
	func _compile(data : Variant) -> void:
		var form := data as Dictionary
		if not (
			compile_extends_default(form) and 
			compile_id_default(form) and
			compile_is_end_default(form) and
			compile_goto_default(form)
		):
			return
		_set_is_valid(true)

class _Default extends _Element:
	func _compile(data : Variant) -> void:
		var form := data as Dictionary
		if not (
			compile_extends_default(form) and 
			compile_id_default(form) and
			compile_is_end_default(form) and
			compile_goto_default(form)
		):
			return
		_set_is_valid(true)

## 元素类型。
const META_TYPE := 0

## 元素名称。
var element_name : String
## 作用指令。
var command : Array

func _compile(data : Variant) -> void:
	var from := data as Dictionary
	
	var ele := ElementRuleCompiler.new()
	ele.element_name = element_name
	ele.compile(data)
	
	_add_error_from_object(ele)
	if not ele.is_valid():
		return
	cmd_list_types = ele.cmd_list_types
	compiled_result = ele.get_result()
	var type := compiled_result[META_TYPE] as int
	
	var obj : _Element
	match type:
		GrammarValue.Type.OPTION: obj = _Option.new()
		GrammarValue.Type.NIL: obj = _Nil.new()
		_: obj = _Default.new()
	
	obj.compiled_result = compiled_result
	obj.command = command
	obj.element = element_name
	obj.compile(from)
	
	_add_error_from_object(obj)
	if not obj.is_valid():
		return
	compiled_result.merge(obj.get_result())
	_set_is_valid(true)

