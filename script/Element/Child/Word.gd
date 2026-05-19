class_name WordElement
extends StringElement
## 不包括任何符号的元素。

func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data : FunctionCompletionData = ElementRuleCMD.execute_completion(column, rule, command) if rule.has_cmd() else FunctionCompletionData.new()
	data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
	data.hint_string = "<%s : word>" % [rule.get_description()]
	return data
static func get_precast_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data : FunctionCompletionData = ElementRuleCMD.execute_completion(column, rule, command) if rule.has_cmd() else FunctionCompletionData.new()
	data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
	data.hint_string = "<%s : word>" % [rule.get_description()]
	return data

# 搜索的正则表达式。
static var _search_word_regex := RegEx.create_from_string(r"^\p{Z}*(?<word>[\p{L}\p{Pc}]+)")
static func create(text : String, offset : int) -> WordElement:
	return _create_word_element(WordElement.new(), text, offset)

## 这个函数应该是 Protected，在一个模板上创建。
static func _create_word_element(element : StringElement, text : String, offset : int) -> StringElement:
	element.string_offset = offset
	
	var result := _search_word_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find any word.")
		return element
	
	element.valid_start = result.get_start("word")
	element.string = result.get_string()
	element.is_faild = false
	return element

## 获取分割符。
func get_separator() -> String:
	is_faild_assert()
	return string.substr(0, valid_start)
