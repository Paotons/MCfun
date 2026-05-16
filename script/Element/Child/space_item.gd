class_name SpaceItemElement
extends DoubleParamElement
## 空间物品。
##
## 把空间看作键，把物品看做值。

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	if has_key():
		result[get_key_start()] = {"color" : edit.color_space}
		result[get_key_end()] = {"color" : edit.color_default}
	if has_value():
		result[get_value_start()] = {"color" : edit.color_stringname}
		result[get_value_end()] = {"color" : edit.color_default}
	return result

static var _spaceitem_search_regex := RegEx.create_from_string(
	r"^(?<start> *)(?=[^ \t])(?<space>[^ \t^:,]+(?=:))?(?<flag>:)?(?<item>[^ \t:,]+)?"
	)
static func create(text : String, offset : int) -> SpaceItemElement:
	var element := SpaceItemElement.new()
	element.string_offset = offset
	var result := _spaceitem_search_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find string.")
		return element
	element.valid_start = result.get_end("start")
	
	element.value_start = result.get_start("item")
	element.value_end = result.get_end("item")
	element.key_start = result.get_start("space")
	element.key_end = result.get_end("space")
	element.string = result.get_string()
	element.is_faild = false
	return element

static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	var entry := EditManager.get_grammer_entry()
	var chapter_name : String = rule.spaceitem_get_category() if rule.has_detail() else ""
	data.hint_string = "<%s : space_item>" % [rule.get_description()]
	if entry.has_chapter(chapter_name):
		var chapter := entry.get_chapter(chapter_name) as GrammarSpaceItemChapter
		data.insert_texts.append_array(chapter.get_items(EditManager.get_edit().spaceitem_expleation_included_space))
		data.fill_insert_mode(CodeCompletionData.InsertMode.SPACEITEM)
	return data
func _get_column_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	var entry := EditManager.get_grammer_entry()
	var chapter_name : String = rule.spaceitem_get_category() if rule.has_detail() else ""
	data.hint_string = "<%s : space_item>" % [rule.get_description()]
	if entry.has_chapter(chapter_name):
		var chapter := entry.get_chapter(chapter_name) as GrammarSpaceItemChapter
		data.insert_texts.append_array(chapter.get_items(EditManager.get_edit().spaceitem_expleation_included_space))
		data.fill_insert_mode(CodeCompletionData.InsertMode.SPACEITEM)
	return data

## 如果是空间物品，返回 [code]true[/code]。
static func is_spaceitem(text : String) -> bool:
	var result := _spaceitem_search_regex.search(text)
	if result.get_start("space") == -1:
		if result.get_start("flag") != -1:
			return false
		else:
			return true
	else:
		if not result.get_start("flag") != -1:
			return true
		else:
			return false

