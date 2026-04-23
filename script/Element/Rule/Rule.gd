class_name ElementRule
extends Resource
## 结果的规则。
##
## 用于给各种结果提供给结果的。内涵 [code]type, detail, items, description[/code] 参数。

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

## 数据。
var data_main : Dictionary[int, Variant]

## 获取 类型。
func get_type() -> GrammerValue.Type:
	return data_main[META_TYPE]
## 获取类型的字符串。
func get_type_string() -> String:
	return GrammerValue.type_to_string(get_type())

## 如果有描述，返回 [code]true[/code]。
func has_description() -> bool:
	return data_main.has(META_DESCRIPTION)
## 获取描述。
func get_description(idx := 0) -> String:
	if not has_description():
		return "Unknow"
	var description = data_main[META_DESCRIPTION]
	if description is PackedStringArray:
		return description[mini(description.size() - 1, idx)]
	else:
		return description

## 获取项。
func get_items() -> Array:
	return data_main[META_ITEMS] if data_main.has(META_ITEMS) else []

## 如果有类型详请，返回 [code]true[/code]。
func has_detail() -> bool:
	return data_main.has(META_DETAIL)
## 如果是命名物品，获取它的补全类。
func spaceitem_get_category() -> String:
	if get_type() != GrammerValue.Type.SPACEITEM:
		push_error("The type of command compiled_data_main is %s." % [GrammerValue.type_to_string(get_type())])
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""

## 如果是选项，并且使用条目，则返回 [code]true[/code]。
func is_option_using_entry() -> bool:
	return data_main[META_DETAIL][_DETAIL_OPTION_USING_ENTRY]
## 如果是选项，获取 [param string] 在其中的序列。
func get_option_string_index(string : String) -> int:
	if is_option_using_entry():
		var items := get_items()
		var entry := GL.get_grammer_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammerStringChapter
			if chapter.has_item(string): return i
	else:
		return get_items().find(string)
	return -1
##如果是取选项，获取其补全项目。
func get_option_items() -> PackedStringArray:
	if is_option_using_entry():
		var res : PackedStringArray
		var items := get_items()
		var entry := GL.get_grammer_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammerStringChapter
			res.append_array(chapter.get_items())
		return res
	else:
		return get_items()

## 如果是点号路径，获取它的章节名称。
func get_point_path_chapter_name() -> String:
	if get_type() != GrammerValue.Type.POINT_PATH:
		push_error("The type of command compiled_data_main is %s." % [GrammerValue.type_to_string(get_type())])
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
## 如果是字典，获取它的补全规则。
func get_point_path_chapter() -> GrammerChapter:
	if get_type() != GrammerValue.Type.POINT_PATH:
		assert("The type of command compiled_data_main is %s." % [GrammerValue.type_to_string(get_type())])
	var entry := GL.get_grammer_entry()
	var name : String = data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
	return entry.get_chapter(name) if entry.has_chapter(name) else null

## 如果有指令，返回 [code]true[/code]。
func has_cmd() -> bool:
	return data_main.has(META_CMD)
## 返回指令。
func get_cmd() -> Array:
	return data_main[META_CMD] if has_cmd() else []

#region 规则。
## 获取规则名称，仅限于可以获取到类型([code]array, dictionary[/code])。
func get_rule_name() -> String:
	match get_type():
		GrammerValue.Type.DICTIONARY: return _get_dictionary_rule_name()
		GrammerValue.Type.ARRAY: return _get_array_rule_name()
		GrammerValue.Type.QUOTATION: return _get_param_backet_rule_name()
	return ""
## 获取规则。
func get_rule() -> GrammerRule:
	var name := get_rule_name()
	return GL.get_grammer_law().get_rule(name)

# 如果是字典，获取它的补全规则名称。
func _get_dictionary_rule_name() -> String:
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
# 如果是数组，获取它的补全规则名称。
func _get_array_rule_name() -> String:
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
# 如果是参数括号，获取它的规则名称。
func _get_param_backet_rule_name() -> String:
		return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
#endregion

## 获取自定义数据。
func get_custom() -> Variant:
	return data_main[META_CUSTOM] if data_main.has(META_CUSTOM) else null

#region 解析
## 解析，将原始字典转化成解析字典，失败返回 [code]null[/code]。
static func compile(dat : Dictionary) -> Variant:
	var compiled_data_main : Dictionary[int, Variant]
	var type : GrammerValue.Type
	
	if _compile_meta_type(dat, compiled_data_main):
		return null
	type = compiled_data_main[META_TYPE]
	
	match type:
		GrammerValue.Type.OPTION: if _compile_option(dat, compiled_data_main): return null
		GrammerValue.Type.NIL: if _compile_nil(dat, compiled_data_main): return null
		_: if _compile_default(dat, compiled_data_main): return null
	if ElementRuleCMD.compile(dat, compiled_data_main):
		return null
	return compiled_data_main

# 解析元素 type，失败返回真。
static func _compile_meta_type(from : Dictionary, to : Dictionary) -> bool:
	if from.has("type"):
		if not from.type is String:
			push_error("The meta named type is %s." % [type_string(typeof(from.type))])
			return true
		var type := GrammerValue.string_to_type(from.type)
		if type == GrammerValue.Type.ERR:
			push_error("Cant use the meta name type called %s." % [from.type])
			return true
		to[META_TYPE] = type
		return false
	else:
		to[META_TYPE] = GrammerValue.Type.NIL
		return false
# 解析选项元素。
static func _compile_option(from : Dictionary, to : Dictionary) -> bool:
	if _compile_option_detail(from, to): return true
	if _compile_meta_array(from, to, "items", META_ITEMS, TYPE_STRING, true): return true
	if _compile_meta_array(from, to, "description", META_DESCRIPTION, TYPE_STRING): return true
	if from.has("custom"): to[META_CUSTOM] = from.custom
	return false
# 解析占位，空元素。
static func _compile_nil(from : Dictionary, to : Dictionary) -> bool:
	if _compile_meta_value(from, to, "detail", META_DETAIL, TYPE_STRING): return true
	if _compile_meta_array(from, to, "items", META_ITEMS, TYPE_STRING): return true
	if _compile_meta_value(from, to, "description", META_DESCRIPTION, TYPE_STRING): return true
	if from.has("custom"): to[META_CUSTOM] = from.custom
	return false
# 解析默认元素。
static func _compile_default(from : Dictionary, to : Dictionary) -> bool:
	if _compile_meta_value(from, to, "detail", META_DETAIL, TYPE_STRING): return true
	if _compile_meta_value(from, to, "items", META_ITEMS, TYPE_ARRAY): return true
	if _compile_meta_value(from, to, "description", META_DESCRIPTION, TYPE_STRING): return true
	if from.has("custom"): to[META_CUSTOM] = from["custom"]
	return false

# 解析选项细的细节。
static func _compile_option_detail(from : Dictionary, to : Dictionary) -> bool:
	var detail := _DETAIL_OPTION_DEFAILT.duplicate()
	if not from.has("detail"): pass
	elif not from["detail"] is String:
		push_error("Option detail should be string, but is \"%s\"." % [type_string(typeof(from["detail"]))])
		return true
	else:
		for string in (from["detail"] as String).split(",", false):
			if string == "using_entry": detail[_DETAIL_OPTION_USING_ENTRY] = true
			else:
				push_warning("No meaning detail \"%s\"." % [string])
	to[META_DETAIL] = detail
	return false

## [b]Protected:[/b] 解析任意变量的元素，失败返回真。
static func _compile_meta_value(from : Dictionary, to : Dictionary, meta_string : String, meta : int, type : int, must_has := false, default : Variant = null) -> bool:
	if type == TYPE_INT:
		return _compile_meta_int(from, to, meta_string, meta, must_has, default)
	if from.has(meta_string):
		if typeof(from[meta_string]) == type:
			to[meta] = from[meta_string]
			return false
		else:
			push_error("Meta named is_end is %s." % [type_string(typeof(from[meta_string]))])
			return true
	elif must_has:
		if type != TYPE_NIL and default != null:
			to[meta] = default
			return false
		push_error("from must has meta named %s." % [meta_string])
		return true
	else:
		return false
# 解析 [int] 类型的元素，失败返回真。
static func _compile_meta_int(from : Dictionary, to : Dictionary, meta_string : String, meta : int, must_has := false, default : Variant = null) -> bool:
	if from.has(meta_string):
		if from[meta_string] is float:
			to[meta] = int(from[meta_string])
			return false
		else:
			push_error("Meta named %s is %s." % [meta_string, type_string(typeof(from[meta_string]))])
			return true
	elif must_has:
		if default != null:
			to[meta] = default
			return false
		push_error("from must has meta named %s." % [meta_string])
		return true
	else:
		return false

## [b]Protected:[/b] 解析数组元素，可指定数组的变量类型，失败返回真。
static func _compile_meta_array(from : Dictionary, to : Dictionary, meta_string : String, meta : int, type : int, must_has := false) -> bool:
	if from.has(meta_string):
		if typeof(from[meta_string]) == TYPE_ARRAY:
			for value in from[meta_string]:
				if not typeof(value) == type:
					return true
			to[meta] = from[meta_string]
			return false
		else:
			push_error("Meta named is_end is %s." % [type_string(typeof(from[meta_string]))])
			return true
	elif must_has:
		push_error("from must has meta named %s." % [meta_string])
		return true
	else:
		return false
#endregion
