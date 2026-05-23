class_name NativeCommandElement
extends ProcessCommandElement
## 本地指令。

func _get_process() -> GrammarProcess:
	return EditManager.get_grammar_native_process()

static func create(text : String, offset : int, line := -1) -> NativeCommandElement:
	var element := NativeCommandElement.new()
	
	# 初始化。
	element.command_type = CommandElementManager.CommandType.NATIVE
	element.string_offset = offset
	element.string = text.substr(offset)
	element._highlight_data = HightLightData.new()
	
	# 进程。
	var process :=CommandElementCreaterProcess.new()
	
	process.edit = EditManager.get_edit()
	process.grammar = EditManager.get_grammar_native_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = line
	
	process.offset = offset
	
	element._line_id = process.edit.get_line_id(line)
	
	var creater := NativeCommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	return element

func _get_column_code_completion_data(column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	if is_column_outside_valid(column): # 不在范围。
		return null
	elif is_column_at_head(column): # 在头部。
		return EditManager.get_grammar_native_process().get_head_completion_data()
	
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
			var result : StringElement = get_element(idx)
			return result.get_column_code_completion_data(column, exe, self)
	return null
static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	return EditManager.get_grammar_native_process().get_head_completion_data()

func is_column_at_head(column : int) -> bool:
	if column <= string_offset: return false
	
	if is_empty(): return true
	return column <= get_valid_start() + head_string.length() + 1



