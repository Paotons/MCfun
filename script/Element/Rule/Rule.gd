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
var data_main : Dictionary

## 获取 类型。
func get_type() -> GrammarValue.Type:
	return data_main[META_TYPE]
## 获取类型的字符串。
func get_type_string() -> String:
	return GrammarValue.type_to_string(get_type())

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
	if get_type() != GrammarValue.Type.SPACEITEM:
		push_error("The type of command compiled_data_main is %s." % [GrammarValue.type_to_string(get_type())])
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""

## 如果是选项，并且使用条目，则返回 [code]true[/code]。
func is_option_using_entry() -> bool:
	return data_main[META_DETAIL][_DETAIL_OPTION_USING_ENTRY]
## 如果是选项，获取 [param string] 在其中的序列。
func get_option_string_index(string : String) -> int:
	if is_option_using_entry():
		var items := get_items()
		var entry := EditManager.get_grammar_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammarStringChapter
			if chapter == null:
				push_error("Not has chapter \"%s\"" % items[i])
				continue
			if chapter.has_item(string): return i
	else:
		return get_items().find(string)
	return -1
##如果是取选项，获取其补全项目。
func get_option_items() -> PackedStringArray:
	if is_option_using_entry():
		var res : PackedStringArray
		var items := get_items()
		var entry := EditManager.get_grammar_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammarStringChapter
			if chapter == null:
				push_error("Not has chapter \"%s\"" % items[i])
				continue
			res.append_array(chapter.get_items())
		return res
	else:
		return get_items()

## 如果是点号路径，获取它的章节名称。
func get_point_path_chapter_name() -> String:
	if get_type() != GrammarValue.Type.POINT_PATH:
		push_error("The type of command compiled_data_main is %s." % [GrammarValue.type_to_string(get_type())])
	return data_main[META_DETAIL] if data_main.has(META_DETAIL) else ""
## 如果是字典，获取它的补全规则。
func get_point_path_chapter() -> GrammarChapter:
	if get_type() != GrammarValue.Type.POINT_PATH:
		assert("The type of command compiled_data_main is %s." % [GrammarValue.type_to_string(get_type())])
	var entry := EditManager.get_grammar_entry()
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
		GrammarValue.Type.DICTIONARY: return _get_dictionary_rule_name()
		GrammarValue.Type.ARRAY: return _get_array_rule_name()
		GrammarValue.Type.QUOTATION: return _get_param_backet_rule_name()
	return ""
## 获取规则。
func get_rule() -> GrammarRule:
	var name := get_rule_name()
	return EditManager.get_grammar_law().get_rule(name)

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
