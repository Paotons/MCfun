class_name AnnotationCommandElement
extends BaseCommandElement
## 注释指令。

static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : CommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.insert_texts.append_array(["#"])
	return data
func _get_column_code_completion_data(_column : int, _rule : ElementRule, _command : CommandElement) -> FunctionCompletionData:
	return null

static func create(text : String, offset : int, line := -1) -> AnnotationCommandElement:
	var element := AnnotationCommandElement.new()
	element.command_type = CommandElementManager.CommandType.ANNOTATION
	element.string = text.substr(offset)
	element.string_offset = offset
	element._line_id = EditManager.get_edit().get_line_id(line)
	element._highlight_data = HightLightData.new()
	
	var process := CommandElementCreaterProcess.new()
	process.offset = offset
	process.edit = EditManager.get_edit()
	
	var creater := AnnotationCommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	
	return element

func _update(text : String, _column : int) -> AnnotationCommandElement:
	return BaseCommandElement.create(text, string_offset)
