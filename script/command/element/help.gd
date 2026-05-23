class_name HelpCommandElement
extends BaseCommandElement
## 帮助指令。
##
## 类似 [code]help[/code] 指令。

func _get_column_code_completion_data(_column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	return EditManager.get_grammar_process().get_head_completion_data()
static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.insert_texts.append_array(["?"])
	return data

static func create(text : String, offset : int, line := -1) -> HelpCommandElement:
	var element := HelpCommandElement.new()
	element.command_type = CommandElementManager.CommandType.HELP
	element.string = text.substr(offset)
	element.string_offset = offset
	element._line_id = EditManager.get_edit().get_line_id(line)
	element._highlight_data = HightLightData.new()
	
	var process := CommandElementCreaterProcess.new()
	process.edit = EditManager.get_edit()
	process.offset = offset
	
	var creater := HelpCommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	
	return element

func _update(text : String, _column : int) -> BaseCommandElement:
	return BaseCommandElement.create(text, string_offset, get_line_index())
