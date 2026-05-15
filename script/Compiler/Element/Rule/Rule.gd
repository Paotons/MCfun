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
			_try_dictionary_key_direct(from, "%s[detail]" % element, "detail", META_DETAIL, false) and
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
	
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if not _compile_detail(from):
			return
		if not (
			_try_dictionary_key(from, "%s[items]" % element, "items", META_ITEMS, true,
				_test_value_array_types.bind(1 << TYPE_STRING, "%s[items]" % element),
			) and
			_try_dictionary_key(from, "%s[custom]" % element, "custom", META_CUSTOM, false)
		):
			return
		
		var size := (compiled_result[META_ITEMS] as Array).size()
		if not _try_dictionary_key(from, "%s[description]" % element, "description", META_DESCRIPTION, false,
			_test_value_array_types.bind(1 << TYPE_STRING, "%s[description]" % element, size),
		):
			return
		_set_is_valid(true)
		
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
			_try_dictionary_key(from, "%s[detail]" % element, "detail", META_DETAIL, false,
				_test_value_type.bind(1 << TYPE_STRING, "%s[detail]" % element)
			) and
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
	var type : GrammerValue.Type = compiled_result[META_TYPE]
	
	var obj : _Element
	match type:
		GrammerValue.Type.OPTION: obj = _Option.new()
		GrammerValue.Type.NIL: obj = _Nil.new()
		_: obj = _Default.new()
	
	obj.element = element_name
	obj.compile(from)
	
	if not obj.is_valid():
		return
	compiled_result.merge(obj.get_result())
	_set_is_valid(true)

# 解析元素 type。
func _compile_type(from : Dictionary) -> bool:
	if not from.has("type"):
		compiled_result[META_TYPE] = GrammerValue.Type.NIL
		return true
	
	if not _test_value_type(from["type"], 1 << TYPE_STRING, element_name):
		return false
		
	var type := GrammerValue.string_to_type(from["type"])
	if type == GrammerValue.Type.ERR:
		errors.append("%s type is %s, but can not used." % [element_name, from["type"]])
		return false
	
	compiled_result[META_TYPE] = type
	return true

