class_name ElementRule
extends Resource
## 结果的规则。
##
## 用于给各种结果提供给结果的。内涵 [code]type, detail, items, description[/code] 参数。
# 唉，挺想拆成各种类型的，就是还要兼容 Exe，将就一起。

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

# 选项物体的物体。
const _ITEMS_OPTION_ITEMS := 0
# 选项物体的显示。
const _ITEMS_OPTION_DISPLAYS := 1
#endregion

#region 细节。
const _DETAIL_OPTION_USING_ENTRY := 0
const _DETAIL_ARRAY_RULE := 0
const _DETAIL_DICTIONARY_RULE := 0
const _DETAIL_QUOTATION_RULE := 0
const _DETAIL_SPACE_ITEM_CHAPTER := 0
const _DETAIL_POINT_PATH_CHAPTER := 0
const _DETAIL_STRING_IS_LONG := 0
const _DETAIL_RICH_STRING_IS_LONG := 0
const _DETAIL_COMMAND_TYPES := 0
const _DETAIL_SELECTOR_ASTERISK := 0

const _DETAIL_FILE_PATH_EXTENSIONS := 0
const _DETAIL_FILE_PATH_USING_EXTENSION := 1
#region

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

## 如果是指令，返回它的类型。
func get_command_types() -> int:
	return _get_detail()[_DETAIL_COMMAND_TYPES] if data_main.has(META_DETAIL) else 0xFFFFFFFF

#region 目标选择器。
func has_selector_asterisk() -> bool:
	return _get_detail()[_DETAIL_SELECTOR_ASTERISK] if data_main.has(META_DETAIL) else false
#endregion

#region 选项。
## 如果是选项，并且使用条目，则返回 [code]true[/code]。
func is_option_using_entry() -> bool:
	return _get_detail()[_DETAIL_OPTION_USING_ENTRY] if data_main.has(META_DETAIL) else false
## 如果是选项，获取 [param string] 在其中的序列。
func get_option_string_index(string : String) -> int:
	if is_option_using_entry():
		var items := _get_option_items()
		var entry := EditManager.get_grammar_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammarStringChapter
			if chapter == null:
				push_error("Not has chapter \"%s\"" % items[i])
				continue
			if chapter.has_item(string): return i
	else:
		return _get_option_items().find(string)
	return -1
## 如果选项，获取其补全项目。
func get_option_items() -> PackedStringArray:
	if is_option_using_entry():
		var res : PackedStringArray
		var items := _get_option_items()
		var entry := EditManager.get_grammar_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammarStringChapter
			if chapter == null:
				push_error("Not has chapter \"%s\"" % items[i])
				continue
			res.append_array(chapter.get_items())
		return res
	else:
		return _get_option_items()
## 如果是选项，获取其补全项目的显示文本。
func get_option_displays() -> PackedStringArray:
	if is_option_using_entry():
		var res : PackedStringArray
		var items := _get_option_items()
		var entry := EditManager.get_grammar_entry()
		for i in items.size():
			var chapter := entry.get_chapter(items[i]) as GrammarStringChapter
			if chapter == null:
				push_error("Not has chapter \"%s\"" % items[i])
				continue
			res.append_array(chapter.get_displays())
		return res
	else:
		return _get_option_displays()
#endregion

#region is_long
## 如果是长元素，返回 [code]true[/code]。
func is_long() -> bool:
	match get_type():
		GrammarValue.Type.STRING: return _is_string_long()
		GrammarValue.Type.RICH_STRING: return _is_rich_string_long()
		_: return false

func _is_string_long() -> bool:
	return _get_detail()[_DETAIL_STRING_IS_LONG] if data_main.has(META_DETAIL) else false
func _is_rich_string_long() -> bool:
	return _get_detail()[_DETAIL_RICH_STRING_IS_LONG] if data_main.has(META_DETAIL) else false
#endregion

#region 章节。
## 获取章节。
func get_chapter_name() -> String:
	match get_type():
		GrammarValue.Type.POINT_PATH : return _get_point_path_chapter_name()
		GrammarValue.Type.SPACEITEM : return _get_spaceitem_chapter()
		_ : return ""
## 获取章类。
func get_chapter() -> GrammarChapter:
	var name := get_chapter_name()
	return EditManager.get_grammar_entry().get_chapter(name)

# 如果是点号路径，获取它的章节名称。
func _get_point_path_chapter_name() -> String:
	return _get_detail()[_DETAIL_POINT_PATH_CHAPTER] if data_main.has(META_DETAIL) else ""
## 如果是命名物品，获取它的补全类。
func _get_spaceitem_chapter() -> String:
	return _get_detail()[_DETAIL_SPACE_ITEM_CHAPTER] if data_main.has(META_DETAIL) else ""
#endregion
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
	return _get_detail()[_DETAIL_DICTIONARY_RULE] if data_main.has(META_DETAIL) else ""
# 如果是数组，获取它的补全规则名称。
func _get_array_rule_name() -> String:
	return _get_detail()[_DETAIL_ARRAY_RULE] if data_main.has(META_DETAIL) else ""
# 如果是参数括号，获取它的规则名称。
func _get_param_backet_rule_name() -> String:
		return _get_detail()[_DETAIL_QUOTATION_RULE] if data_main.has(META_DETAIL) else ""
#endregion

#region 文件。
## 如果是文件路径，返回可用扩展名。
func get_file_path_extensions() -> PackedStringArray:
	return _get_detail()[_DETAIL_FILE_PATH_EXTENSIONS] if data_main.has(META_DETAIL) else PackedStringArray()
## 如果是文件路径，使用扩展名，返回 [code]true[/code]。
func is_file_path_using_extension() -> bool:
	return _get_detail()[_DETAIL_FILE_PATH_USING_EXTENSION] if data_main.has(META_DETAIL) else true
#endregion

#region cmd
## 如果有指令，返回 [code]true[/code]。
func has_cmd() -> bool:
	return data_main.has(META_CMD)
## 返回指令。
func get_cmd() -> Array:
	return data_main[META_CMD] if has_cmd() else []
#endregion

## 获取自定义数据。
func get_custom() -> Variant:
	return data_main[META_CUSTOM] if data_main.has(META_CUSTOM) else null

# 获取选项物体的物体。
func _get_option_items() -> PackedStringArray:
	return data_main[META_ITEMS][_ITEMS_OPTION_ITEMS]
# 获取选项物体的显示。
func _get_option_displays() -> PackedStringArray:
	return data_main[META_ITEMS][_ITEMS_OPTION_DISPLAYS]

# 获取 deail。
func _get_detail() -> Array:
	return data_main[META_DETAIL]
