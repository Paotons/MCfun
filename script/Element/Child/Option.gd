class_name OptionElement
extends StringElement
## 选项元素。

## 选项序列。
var option_index := -1
## 指令物品。
var element_rule : ElementRule

static func create(text : String, offset : int, rule : ElementRule = null) -> OptionElement:
	var element : OptionElement = _create_string_element(OptionElement.new(), text, offset)
	element.element_rule = rule
	
	if element.is_faild:
		return element
	var valid_str := element.get_valid_string()
	
	element.element_rule = rule
	
	element.option_index = rule.get_option_string_index(valid_str)
	if element.option_index == -1:
		element.create_error(offset, "Not has option \"%s\"." % [valid_str])
	return element
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_option if has_option() else edit.color_error_option}, get_valid_end() : {"color" : edit.color_default}}
func _get_column_code_completion_data(_column : int, _rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.insert_texts.append_array(element_rule.get_option_items())
	data.fill_insert_mode(CodeCompletionData.InsertMode.WORLD)
	return data
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.insert_texts.append_array(rule.get_option_items())
	data.fill_insert_mode(CodeCompletionData.InsertMode.WORLD)
	return data

## 如果有序列，返回 [code]true[/code]。
func has_option() -> bool:
	is_faild_assert()
	return option_index != -1
