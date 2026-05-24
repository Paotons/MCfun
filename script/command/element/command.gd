class_name CommandElement
extends ProcessCommandElement
## 指令。
##
## 最普通的指令。

func _get_process() -> GrammarProcess:
	return EditManager.get_grammar_process()

static func create(text : String, offset : int, line := -1) -> CommandElement:
	var element := CommandElement.new()
	
	# 初始化。
	element.command_type = CommandElementManager.CommandType.NORMAL
	element.string_offset = offset
	element.string = text.substr(offset)
	element._highlight_data = HightLightData.new()
	
	# 进程。
	var process :=CommandElementCreaterProcess.new()
	
	process.edit = EditManager.get_edit()
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = line
	
	process.offset = offset
	
	element._line_id = process.edit.get_line_id(line)
	
	var creater := CommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	return element
## [param column] 发生更新。
func _update(text : String, column : int) -> CommandElement:
	var offset := string_offset
	var edit := EditManager.get_edit()
	
	# 进程。
	var process := CommandElementCreaterProcess.new()
	
	process.edit = edit
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = get_line_index()
	
	process.offset = offset
	
	var creater := CommandElementCreater.new()
	creater.command = self
	return creater.run_from_column(text, process, column)

static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	return EditManager.get_grammar_process().get_head_completion_data()
func _get_column_code_completion_data(column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	if is_column_outside_valid(column): # 不在范围。
		return null
	elif is_column_at_head(column): # 在头部。
		return _get_process().get_head_completion_data()
	
	# 在最后结尾
	if is_column_at_end(column):
		return _get_code_completion_next(column)
	
	var idx := get_column_map_index(column)
	if idx == -1: return null
	
	var command_idx := get_history(idx)
	var exe := get_exe_element(command_idx)
	
	assert(exe.get_type() != GrammarValue.Type.NIL, "IS nil.")
	# 为当前做补全
	match exe.get_type():
		GrammarValue.Type.COMMAND:
			var element : BaseCommandElement = get_element(idx)
			if element.command_type & CommandElementManager.CommandType.REPLACE != 0:
				return _get_process().get_head_completion_data() if element.is_faild else element.get_column_code_completion_data(column, exe, self)
		_:
			var result : BaseStringElement = get_element(idx)
			return result.get_column_code_completion_data(column, exe, self)
	return null
