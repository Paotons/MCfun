class_name BoolElement
extends BaseStringElement
## 选项元素。

# 布尔选项。
const _BOOL_OPTION : PackedStringArray = ["false", "true"]

## 值。
var bool_value := -1

static func create(text : String, offset : int) -> BoolElement:
	var element : BoolElement = StringElement._create_string_element(BoolElement.new(), text, offset)
	
	if element.is_faild:
		return element
	var valid_str := element.get_valid_string()
	
	element.bool_value = _BOOL_OPTION.find(valid_str)
	if element.bool_value == -1:
		element.create_error(offset, "Not has option \"%s\"." % [valid_str])
		element.is_faild = true
	return element
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_bool}, get_valid_end() : {"color" : edit.color_default}}
func _get_column_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : bool>" % [rule.get_description()]
	data.insert_texts = _BOOL_OPTION.duplicate()
	data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
	return data
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : bool>" % [rule.get_description()]
	data.insert_texts = _BOOL_OPTION.duplicate()
	data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
	return data

## 如果有值，返回 [code]true[/code]。
func has_bool() -> bool:
	return bool_value != -1
## 获取值，如果没有，返回 [code]false[/code]。
func get_bool() -> bool:
	return false if bool_value == -1 or bool_value == 0 else true if bool_value == 1 else false
