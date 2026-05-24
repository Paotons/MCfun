class_name ElementRuleCompiler
extends Compiler
## 元素规则的解析器。

class _Element extends Compiler:
	var element : String

class _Default extends _Element:
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if not (
			_try_dictionary_key_direct(from, "%s[items]" % element, "items", META_ITEMS, false) and
			_try_dictionary_key(from, "%s[description]" % element, "description", META_DESCRIPTION, false,
				_test_value_type.bind(1 << TYPE_STRING, "%s[description]" % [element]),
			 ) and
			_try_dictionary_key_direct(from, "%s[custom]" % element, "custom", META_CUSTOM, false)
		):
			return
		_set_is_valid(true)

class _Option extends _Element:
	# 要用空间标识。
	const _DETAIL_USING_ENTRY := 0
	const _DETAIL_DEFAILT := [false]
	
	# 选项物体的物体。
	const _ITEMS_ITEMS := 0
	# 选项物体的显示。
	const _ITEMS_DISPLAYS := 1
	
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if not from.has("items"):
			errors.append("%s not has items." % element)
			return
		
		var items = from["items"]
		if not _test_value_type(items, 1 << TYPE_ARRAY, "%s[items]" % element):
			return
		if items is Array:
			if not _compile_items_v1(items):
				return
		
		if not _try_dictionary_key(from, "%s[custom]" % element, "custom", META_CUSTOM, false):
			return
		
		if not _try_dictionary_key(from, "%s[description]" % element, "description", META_DESCRIPTION, false,
			_test_value_array_types.bind(1 << TYPE_STRING, "%s[description]" % element),
		):
			return
		_set_is_valid(true)
	
	func _compile_items_v1(from : Array) -> bool:
		if not _test_array_types(from, 1 << TYPE_STRING | 1 << TYPE_DICTIONARY, "%s[items]" % element):
			return false
		
		var keys : PackedStringArray
		var values : PackedStringArray
		for i in from.size():
			var value = from[i]
			if value is String:
				keys.append(value)
				values.append("")
			elif value is Dictionary:
				if not _test_dictionary_key_types(value, 1 << TYPE_STRING, "%s[item][%d]" % [element, i]):
					return false
				elif not _test_dictionary_value_types(value, 1 << TYPE_STRING, "%s[item][%d]" % [element, i]):
					return false
				keys.append(value.keys().back())
				values.append(value.values().back())
		
		compiled_result[META_ITEMS] = [keys, values]
		return true
	
	# 字典无法保证与 goto 的顺序。
	func _compile_items_v2(from : Dictionary) -> bool:
		if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "%s[items]" % element):
			return false
		if not _test_dictionary_value_types(from, 1 << TYPE_STRING, "%s[items]" % element):
			return false
		
		var keys := from.keys()
		var values : Array
		values.resize(keys.size())
		for i in keys.size():
			values[i] = from[keys[i]]
		compiled_result[META_ITEMS] = [keys, values]
		return true
	
	func _compile_detail(from : Dictionary) -> bool:
		if not from.has("detail"):
			compiled_result[META_DETAIL] = _DETAIL_DEFAILT.duplicate()
			return true
		
		if not _test_value_type(from["detail"], 1 << TYPE_STRING, "%s[detail]" % element):
			return false
		
		var strings := from["detail"] as String
		var detail := _DETAIL_DEFAILT.duplicate()
		for string in strings.split(",", false):
			if string == "using_entry":
				detail[_DETAIL_USING_ENTRY] = true
			else:
				errors.append("%s[detail] unvaild \"%s\"." % [element, string])
		compiled_result[META_DETAIL] = detail
		return true

class _Nil extends _Element:
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if not (
			_try_dictionary_key(from, "%s[items]" % element, "items", META_ITEMS, false,
				_test_array_types.bind(1 << TYPE_STRING, "%s[items]" % element)
			) and
			_try_dictionary_key(from, "%s[description]" % element, "description", META_DESCRIPTION, false,
				_test_value_type.bind(1 << TYPE_STRING, "%s[description]" % element),
			 ) and
			_try_dictionary_key_direct(from, "%s[custom]" % element, "custom", META_CUSTOM, false)
		):
			return
		_set_is_valid(true)

class _Detail extends _Element:
	var value_type : int
	
	# 类型 : 默认值 --- 值
	# Option : [false] --- [using_entry]
	# dict, arr, quot : [""] --- [rule]
	# spa_item, poi_path : [""] -- [chapter]
	# fil_path : [["", true]] --- [extensions, using_extension]
	# string, rich_string : [false] --- [long]
	# command : [0xFFFFFFFF] ---- [types]
	
	func _get_name() -> String:
		return "%s[items]" % element
	func _compile(data : Variant) -> void:
		if not _test_value_type(data, 1 << TYPE_STRING | 1 << TYPE_DICTIONARY, _get_name()):
			return
		
		if data is String:
			_compile_v1(data)
		elif data is Dictionary:
			_compile_v2(data)
	
	func _compile_v1(from : String) -> void:
		match value_type:
			GrammarValue.Type.OPTION:
				compiled_result = [true] if from == "using_entry" else [false]
			GrammarValue.Type.DICTIONARY, GrammarValue.Type.ARRAY, GrammarValue.Type.QUOTATION:
				compiled_result = [from]
			GrammarValue.Type.SPACEITEM, GrammarValue.Type.POINT_PATH:
				compiled_result = [from]
			GrammarValue.Type.FILE_PATH:
				compiled_result = [[from], true]
			GrammarValue.Type.STRING, GrammarValue.Type.RICH_STRING:
				compiled_result = [true] if from == "long" else [false]
			_:
				compiled_result = from
		_set_is_valid(true)
	func _compile_v2(from : Dictionary) -> void:
		if not _test_dictionary_key_types(from, 1 << TYPE_STRING, _get_name()):
			return
		
		match value_type:
			GrammarValue.Type.OPTION:
				if from.has("using_entry") and not _test_value_type(from["using_entry"], 1 << TYPE_BOOL, "%s[using_entry]" % _get_name()):
					return
				compiled_result = [from.get("using_entry", false)]
			GrammarValue.Type.DICTIONARY, GrammarValue.Type.ARRAY, GrammarValue.Type.QUOTATION:
				if from.has("rule") and not _test_value_type(from["rule"], 1 << TYPE_STRING, "%s[rule]" % _get_name()):
					return
				compiled_result = [from.get("rule", "")]
			GrammarValue.Type.SPACEITEM, GrammarValue.Type.POINT_PATH:
				if from.has("chapter") and not _test_value_type(from["chapter"], 1 << TYPE_STRING, "%s[chapter]" % _get_name()):
					return
				compiled_result = [from.get("chapter", "")]
			GrammarValue.Type.FILE_PATH:
				if from.has("extensions") and not _test_value_type(from["extensions"], 1 << TYPE_ARRAY, "%s[extensions]" % _get_name()):
					return
				elif from.has("using_extension") and not _test_value_type(from["using_extension"], 1 << TYPE_BOOL, "%s[using_extension]" % _get_name()):
					return
				var arr : Array =from.get("extensions", [])
				if not _test_array_types(arr, 1 << TYPE_STRING, "%s[extensions]" % _get_name()):
					return
				compiled_result = [arr, from.get("using_extension", true)]
			GrammarValue.Type.STRING, GrammarValue.Type.RICH_STRING:
				if from.has("long") and not _test_value_type(from["long"], 1 << TYPE_BOOL, "%s[long]" % _get_name()):
					return
				compiled_result = [from.get("long", false)]
			GrammarValue.Type.COMMAND:
				if from.has("types") and not _test_value_type(from["types"], 1 << TYPE_STRING, "%s[types]" % _get_name()):
					return
				compiled_result = [CommandElementManager.string_to_command_type(from.get("types", ""))]
			_:
				compiled_result = from
		_set_is_valid(true)

## 元素名称。
var element_name : String

#region 元素。
## 元素类型。
const META_TYPE := 0
## 元素细节。
const META_DETAIL := 1
## 元素物体。
const META_ITEMS := 2
## 元素描述。
const META_DESCRIPTION := 3
## 指令。
const META_CMD := 4
## 自定义属性。
const META_CUSTOM := 5

# 选项细节。
const _DETAIL_OPTION_USING_ENTRY := 0
# 默认选项细节。
const _DETAIL_OPTION_DEFAILT := [false]
#endregion

func compile(data : Variant) -> void:
	var from := data as Dictionary
	
	compiled_result = {}
	if not _compile_type(from):
		return
	var type : GrammarValue.Type = compiled_result[META_TYPE]
	
	var obj : _Element
	match type:
		GrammarValue.Type.OPTION: obj = _Option.new()
		GrammarValue.Type.NIL: obj = _Nil.new()
		_: obj = _Default.new()
	
	obj.element = element_name
	obj.compile(from)
	
	_add_error_from_object(obj)
	if not obj.is_valid():
		return
	compiled_result.merge(obj.get_result())
	
	if from.has("detail"):
		var det := _Detail.new()
		det.element = element_name
		det.value_type = type
		det.compile(from["detail"])
		
		_add_error_from_object(det)
		if not det.is_valid():
			return
		compiled_result[META_DETAIL] = det.get_result()
	
	ElementRuleCMD.compile(from, compiled_result)
	
	_set_is_valid(true)

# 解析元素 type。
func _compile_type(from : Dictionary) -> bool:
	if not from.has("type"):
		compiled_result[META_TYPE] = GrammarValue.Type.NIL
		return true
	
	if not _test_value_type(from["type"], 1 << TYPE_STRING, element_name):
		return false
		
	var type := GrammarValue.string_to_type(from["type"])
	if type == GrammarValue.Type.ERR:
		errors.append("%s type is %s, but can not used." % [element_name, from["type"]])
		return false
	
	compiled_result[META_TYPE] = type
	return true

