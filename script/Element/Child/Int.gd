class_name IntElement
extends StringElement
## 整数。

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_number}, get_valid_end() : {"color" : edit.color_default}}

static func create(text : String, offset : int) -> IntElement:
	var element := IntElement.new()
	element.string_offset = offset
	
	var result := StringElement.create(text, offset)
	if result.is_faild:
		element.create_error(offset, "Not find string.")
		return element
	
	var valiad_str := result.get_valid_string()
	if valiad_str.is_valid_int():
		element.valid_start = result.valid_start
		element.string = result.string
		element.is_faild = false
		return element
	else:
		element.create_error(offset, "String \"%s\" not is valid int." % [valiad_str])
		return element

static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : int>" % [rule.get_description()]
	return data
func get_column_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : int>" % [rule.get_description()]
	return data
