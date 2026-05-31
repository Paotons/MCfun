class_name CommentCommandElement
extends ProcessCommandElement
## 本地指令。

func _get_process() -> GrammarProcess:
	return EditManager.get_grammar_comment_process()

static func create(text : String, offset : int, line := -1) -> CommentCommandElement:
	var element := CommentCommandElement.new()
	
	# 初始化。
	element.command_type = CommandElementManager.CommandType.COMMENT
	element.string_offset = offset
	element.string = text.substr(offset)
	element._highlight_data = HightLightData.new()
	
	# 进程。
	var process := CommandElementCreaterProcess.new()
	
	process.edit = EditManager.get_edit()
	process.grammar = EditManager.get_grammar_comment_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = line
	
	process.offset = offset
	
	element._line_id = process.edit.get_line_id(line)
	
	var creater := CommentCommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	return element

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
			var data := result.get_column_code_completion_data(column, exe, self)
			data.supple()
			data.add_data(_comment_code_completion(idx))
			return data
	return null
static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	return EditManager.get_grammar_comment_process().get_head_completion_data()
func _get_code_completion_next(column : int) -> FunctionCompletionData:
	var data := super(column)
	for i in get_faild_element_count():
		data.supple()
		var index := get_failld_element_index(i)
		data.add_data(_comment_code_completion(index))
	return data

func is_column_at_head(column : int) -> bool:
	if is_empty(): return true
	return get_valid_start() <= column - 1 and column <= get_valid_start() + head_string.length() + 1

#region 特殊补全。
func _comment_code_completion(idx : int) -> FunctionCompletionData:
	match head_string:
		"list":  return _code_completion_list(idx)
	return
func _code_completion_list(idx : int) -> FunctionCompletionData:
	if idx == 0:
		var data := FunctionCompletionData.new()
		data.insert_texts.append_array(EditManager.get_grammar().get_cmd_list_types())
		data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
		return data
	return
#endregion
