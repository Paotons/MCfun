class_name CommandElement
extends StringElement
## 整条指令。

# 创建的进程。
class _CreateProcess extends RefCounted:
	# 偏移。
	var offset : int
	# 行数。
	var line : int
	
	# 指令规则。
	var rule : CommandRule
	
	# 当前执行元素。
	var exe_element : ExeElementRule
	# 执行序列。
	var exe_index : int
	# 最大执行序列。
	var exe_end : int
	
	# 可结束标志。
	var has_end := false
	
	# 退出标志。
	var break_flag := false
	# 继续标志。
	var continue_flag := false
	
	# 编辑器。
	var edit : FunctionEdit
	# 语法。
	var grammar : GrammarProcess
	# 规则。
	var law : GrammarLaw
	# 字符串。
	var entry : GrammarEntry

## 指令类型。
enum CommandType {
	## 最开始，根部。
	ROOT,
	## 直接替代原来的父指令，直达最后，类型于 execute run 分支一样。
	REPLACE,
}

## 行的 ID。
var line_id := -1
## 指令类型。
var command_type := CommandType.REPLACE
## 元素。
var elements : Array[Element]
## 失败的元素序列，可用于预测下一个参数。
var faild_element_idxs : PackedInt32Array
## 经过的执行元素序列。
var exe_element_histories : PackedInt32Array
## CMD列表。
var cmd_list : Dictionary[int, Dictionary]

## 开头元素。
var head_element : HeadElement
## 头。
var head_string : String

## 高亮数据。
var highlight_data : HightLightData

# 是否有子指令。
var _has_child_element := false

# 头部补全数据。
static var _code_completion_head_data : CodeCompletionData

static func create(text : String, offset : int, line := -1) -> CommandElement:
	var element := CommandElement.new()
	
	# 初始化。
	element.string_offset = offset
	element.string = text.substr(offset)
	element.highlight_data = HightLightData.new()
	
	# 进程。
	var process :=_CreateProcess.new()
	
	process.edit = EditManager.get_edit()
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = line
	
	process.offset = offset
	
	element.line_id = process.edit.get_line_id(line)
	element._do_command_from_empty(text, process)
	return element
## [param column] 发生更新。
func update(text : String, column : int) -> void:
	var offset := string_offset
	var edit := EditManager.get_edit()
	# 初始化。
	faild_element_idxs.clear()
	errors.clear()
	string = text.substr(offset)
	
	# 进程。
	var process :=_CreateProcess.new()
	
	process.edit = edit
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = edit.get_line_index(line_id)
	
	process.offset = offset
	
	_do_command_from_column(text, process, column)

func get_highlight(_edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return highlight_data.data
static func get_precast_code_completion_data(_column : int, _rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	return _code_completion_head_data
func _get_column_code_completion_data(column : int, _rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	if _code_completion_head_data == null: _update_code_completion_head_data()
	
	if is_column_outside_valid(column): # 不在范围。
		return null
	elif is_column_at_head(column): # 在头部。
		return _code_completion_head_data
	
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
			var element : CommandElement = get_element(idx)
			if element.command_type == CommandElement.CommandType.REPLACE:
				return _code_completion_head_data if element.is_faild else element.get_column_code_completion_data(column, exe, self)
		_:
			var result : StringElement = get_element(idx)
			return result.get_column_code_completion_data(column, exe, self)
	return null
# 补全，指令下一个参数。
func _get_code_completion_next(column : int) -> CodeCompletionData:
	var data_main := CodeCompletionData.new()
	
	# 非法头部。
	if not is_valid_head():
		return null
	
	# 上一个是目标选择器
	if is_column_near_selector_head(column):
		data_main.supple()
		data_main.add_data(CodeCompletionData.create_backet_data(GrammarValue.Type.ARRAY))
	
	# 补全下一个元素
	for i in get_faild_element_count():
		var faild_exe := get_faild_element(i)
		
		var data := CodeCompletionData.new()
		var type := faild_exe.get_type()
		match type:
			GrammarValue.Type.DICTIONARY, GrammarValue.Type.ARRAY, GrammarValue.Type.QUOTATION:
				data = CodeCompletionData.create_backet_data(type)
			GrammarValue.Type.COMMAND:
				var index := find_history(faild_exe.get_id())
				var ncommand : CommandElement = get_element(index)
				data = ncommand.get_column_code_completion_data(column, faild_exe, self)
			_:
				var element_type := ElementManager.value_type_to_type(type)
				data = ElementManager.get_precast_code_completion_data(element_type, column, faild_exe, self)
		
		if data != null:
			data_main.supple()
			data_main.add_data(data)
	
	return data_main

# 更新指令头补全的数据。
static func _update_code_completion_head_data() -> void:
	var data := CodeCompletionData.new()
	data.insert_texts.append_array(EditManager.get_grammar_process().get_heads())
	data.fill_insert_mode(CodeCompletionData.InsertMode.WORLD)
	_code_completion_head_data = data

## 获取行数。
func get_line_index() -> int:
	return -1 if line_id == -1 else EditManager.get_edit().get_line_index(line_id)

## 获取头。
func get_head_string() -> String:
	return head_string
## 如果是可用的头，返回 [code]true[/code]。
func is_valid_head() -> bool:
	return EditManager.get_grammar_process().has_head(head_string)

## 如果是空，返回 [code]true[/code]。
func is_empty() -> bool:
	return head_string.is_empty()

## 添加历史。
func add_history(idx : int, element : Element = null) -> void:
	exe_element_histories.append(idx)
	elements.append(element)
## 获取在序列处的历史。
func get_history(idx : int) -> int:
	return exe_element_histories[idx]
## 选找历史。
func find_history(idx : int) -> int:
	return exe_element_histories.find(idx)
## 获取子类指令元素。
func get_children_element(deep := false) -> Array[CommandElement]:
	var result : Array[CommandElement]
	for i in elements:
		if i is CommandElement:
			result.append(i)
			if deep:
				result.append_array(i.get_children_element(true))
	return result

## 获取指令列表。
func get_cmd_list(id : int, column := -1) -> PackedStringArray:
	var result : PackedStringArray
	if _has_child_element:
		for child in get_children_element(true):
			result.append_array(child.get_cmd_list(id, column))
	if not cmd_list.has(id): return result
	column = 0xFFFFFFFF if column == -1 else column
	var list : Dictionary = cmd_list[id]
	for key : int in list:
		if key < column: result.append(list[key])
	return result

#region 序列
## 如果序列前面一个数据是完整的目标选择器头，返回 [code]true[/code]。
func is_column_near_selector_head(column : int) -> bool:
	var size := elements.size()
	for i in size:
		var element := elements[i]
		if element is SelectorElement:
			if element.has_body(): continue
			if i + 1 >= size: return true
			var element2 := elements[i + 1]
			if element2 is SelectorElement:
				return column >= element2.get_head_end() and column < element2.get_valid_start()
	return false
## 判断序列处于有效开头。
func is_column_outside_valid(column : int) -> bool:
	return column <= valid_start
## 判断序列处于头部位置。
func is_column_at_head(column : int) -> bool:
	if column <= string_offset: return false
	
	if is_empty(): return true
	return column <= get_valid_start() + head_string.length()
## 判断序列处于尾部位置。
func is_column_at_end(column : int) -> bool:
	if elements.is_empty():
		return column > valid_start + get_head_string().length()
	var element : Element
	for i in range(1, elements.size() + 1):
		element = elements[elements.size() - i]
		if element != null: break
	return not element is CommandElement and column > element.get_valid_end()
## 获取某个位置在所处的元素序列，返回 [code]-1[/code] 表示非语法上的位置。
func get_column_map_index(column : int) -> int:
	for i in elements.size():
		var element := elements[i]
		if element is CommandElement:
			if element.command_type == CommandElement.CommandType.REPLACE:
				if column > element.string_offset: return i
		elif element is StringElement:
			if element.get_valid_start() < column and column <= element.get_valid_end():
				return i
	return -1
#endregion

#region 元素
## 获取元素。
func get_element(idx : int) -> Element:
	return elements[idx]
## 或取元素数量。
func get_element_count() -> int:
	return elements.size()

## 获取可执行元素规则。
func get_exe_element(idx : int) -> ExeElementRule:
	var grammar := EditManager.get_grammar_process()
	if not grammar.has_head(head_string):
		push_error("Head \"%s\" is unvalid." % [head_string])
		return null
	return grammar.get_item(head_string, idx)

## 返回失败的执行元素。
func get_faild_element(idx : int) -> ExeElementRule:
	return EditManager.get_grammar_process().get_item(head_string, faild_element_idxs[idx])
## 返回失败的执行元素的数量。
func get_faild_element_count() -> int:
	return faild_element_idxs.size()
#endregion

#region 处理。
# 处理函数。
func _do_function(element : ExeElementRule, text : String, process : _CreateProcess) -> bool:
	match element.get_type():
		GrammarValue.Type.NIL : return _do_nil(text, process)
		GrammarValue.Type.BOOL, GrammarValue.Type.INT, GrammarValue.Type.FLOAT, GrammarValue.Type.STRING, GrammarValue.Type.WORD, GrammarValue.Type.RICH_STRING, GrammarValue.Type.POINT_PATH, GrammarValue.Type.SCOPE : 
			return _do_default(text, process)
		
		GrammarValue.Type.OPTION : return _do_option(text, process)
		GrammarValue.Type.COORDS : return _do_coords(text, process)
		GrammarValue.Type.SELECTOR : return _do_selector(text, process)
		GrammarValue.Type.SPACEITEM : return _do_spaceitem(text, process)
		
		GrammarValue.Type.COMMAND : return _do_subcommand(text, process)
		GrammarValue.Type.DICTIONARY : return _do_dictionary(text, process)
		GrammarValue.Type.ARRAY : return _do_array(text, process)
	push_error("Not do.")
	breakpoint
	return true

# 处理开头。
func _do_head(text : String, process : _CreateProcess) -> bool:
	var result := HeadElement.create(text, process.offset) as HeadElement
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	is_faild = false
	valid_start = result.get_valid_start() - process.offset
	
	var head := result.get_valid_string()
	
	highlight_data.merge(result.get_highlight(process.edit))
	head_element = result
	head_string = head
	
	if not process.grammar.has_head(head):
		create_error(result.get_valid_start(), "Unfind command \"%s\"." % [head])
		return true
	
	process.offset = result.get_valid_end()
	return false

# 处理空值，占位。
func _do_nil(_text : String, process : _CreateProcess) -> bool:
	var items := process.exe_element.get_items()
	if items.is_empty(): return false
	for item in items:
		match item:
			"cmp":
				faild_element_idxs.clear()
	add_history(process.exe_index)
	return false

# 默认处理。
func _do_default(text : String, process : _CreateProcess) -> bool:
	var element : StringElement
	var exe_element := process.exe_element
	match process.exe_element.get_type():
		GrammarValue.Type.BOOL : element = BoolElement.create(text, process.offset)
		GrammarValue.Type.INT : element = IntElement.create(text, process.offset)
		GrammarValue.Type.FLOAT : element = FloatElement.create(text, process.offset)
		GrammarValue.Type.STRING: element = StringElement.create(text, process.offset)
		GrammarValue.Type.WORD : element = WordElement.create(text, process.offset)
		GrammarValue.Type.RICH_STRING : element = RichStringElement.create(text, process.offset)
		GrammarValue.Type.POINT_PATH : element = PointPathElement.create(text, process.offset, process.exe_element)
		GrammarValue.Type.SCOPE : element = ScopeElement.create(text, process.offset)
		_: assert("Can do the type \"%s\"." % [process.exe_element.get_type()])
	
	if element.is_faild:
		faild_element_idxs.append(process.exe_index)
		# Err
		if not process.has_end:
			for err in element.errors: create_error(err.column, err.string)
		return true
	for err in element.errors: create_error(err.column, err.string)
	
	# CMD
	if exe_element.has_cmd():
		ElementRuleCMD.execute(element, exe_element, self, ElementRuleCMD.ModeFilter.LIST)
	
	highlight_data.merge(element.get_highlight(process.edit))
	
	process.offset = element.get_valid_end()
	add_history(process.exe_index, element)
	return false

# 处理选项。
func _do_option(text : String, process : _CreateProcess) -> bool:
	var exe := process.exe_element
	var result := OptionElement.create(text, process.offset, exe)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild:
		faild_element_idxs.append(process.exe_index)
		return true
	
	highlight_data.merge(result.get_highlight(process.edit))
	
	if result.has_option():
		process.offset = result.get_valid_end()
		
		add_history(process.exe_index, result)
		
		if exe.has_end():
			process.has_end = exe.is_end()
		
		if exe.has_goto():
			process.exe_index = exe.get_goto(result.option_index)
			process.continue_flag = true
			return false
		
		process.exe_index += 1
		process.continue_flag = true
		return false
	else:
		faild_element_idxs.append(process.exe_index)
	
		process.exe_index += 1
		if exe.has_end():
			process.has_end = exe.is_end()
		process.continue_flag = true
		return true
# 处理坐标。
func _do_coords(text : String, process : _CreateProcess) -> bool:
	var result := CoordsElement.create(text, process.offset)
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	highlight_data.merge(result.get_highlight(process.edit))
	
	add_history(process.exe_index, result)
	process.offset = result.get_valid_end()
	
	return result.get_valid_size() != 3
# 处理目标选择器。
func _do_selector(text : String, process : _CreateProcess) -> bool:
	var result := SelectorElement.create(text, process.offset)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	highlight_data.merge(result.get_highlight(process.edit))
	
	if result.has_body():
		var backet := result.get_body_element()
		for err in backet.errors:
			create_error(err.column, "Body has error \"%s\"." % [err.string])
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false
# 处理空间物品。
func _do_spaceitem(text : String, process : _CreateProcess) -> bool:
	var result := SpaceItemElement.create(text, process.offset)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	highlight_data.merge(result.get_highlight(process.edit))
	if not result.has_value():
		faild_element_idxs.append(process.exe_index)
		return true
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false

#region 处理字典，大括号包括的。
# 入口
func _do_dictionary(text : String, process : _CreateProcess) -> bool:
	var rule := process.exe_element.get_rule()
	if rule == null:
		push_warning("Not find rule \"%s\"." % [process.exe_element.get_rule_name()])
		return _do_dictionary_default(text, process)
	
	match rule.get_type():
		GrammarRule.RuleType.COLON_PARAM_BACKET: return _do_dictionary_colon_param(text, process, rule)
	push_error("Rule is nul type.")
	return true

# 处理冒号参数。
func _do_dictionary_colon_param(text : String, process : _CreateProcess , rule : GrammarRule) -> bool:
	var result := ColonParamBacketElement.create(text, process.offset, "{", "}", rule)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	highlight_data.merge(result.get_highlight(process.edit))
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false
# 默认处理。
func _do_dictionary_default(text : String, process : _CreateProcess) -> bool:
	var sult := BacketElement.create(text, process.offset, "{", "}")
	
	for err in sult.errors: create_error(err.column, err.string)
	if sult.is_faild: return true
	
	process.offset = sult.get_valid_end()
	add_history(process.exe_index, sult)
	return false
#endregion

# 处理数组，中括号包括的，如果是目标选择器，应该就用针对性的目标选择器。
func _do_array(text : String, process : _CreateProcess) -> bool:
	var sult := BacketElement.create(text, process.offset, "[", "]")
	
	for err in sult.errors: create_error(err.column, err.string)
	if sult.is_faild: return true
	
	process.offset = sult.get_valid_end()
	add_history(process.exe_index, sult)
	return false
# 处理指令中的指令。
func _do_subcommand(text : String, process : _CreateProcess) -> bool:
	if process.offset == text.length():
		create_error(process.offset, "Not find command.")
		return true
	
	var result := CommandElement.create(text, process.offset, process.line)
	
	if result.is_empty(): create_error(process.offset, "Not find command.")
	if result.has_error():
		faild_element_idxs.append(process.exe_index)
		for err in result.errors: create_error(process.offset + err.column, err.string)
	
	_has_child_element = true
	highlight_data.merge(result.get_highlight(process.edit))
	add_history(process.exe_index, result)
	return true
#endregion

# 从零开始处理指令。
func _do_command_from_empty(text : String, process : _CreateProcess) -> void:
	if _do_head(text, process):
		return
	
	var head := head_element.get_valid_head()
	process.rule = process.grammar.get_command_rule(head)
	process.exe_index = 0
	process.exe_end = process.rule.get_element_count()
	_do_command_process(text, process)
	_do_command_tail(text, process)
# 从一定位置开始处理指令。
func _do_command_from_column(text : String, process : _CreateProcess, column := 0) -> void:
	var index : int = get_column_map_index(column) - 1 if not is_column_at_end(column) else exe_element_histories.size() - 1
	
	if index < 0: # 相当于重新生成。
		elements.clear()
		exe_element_histories.clear()
		cmd_list.clear()
		highlight_data.data.clear()
		
		if _do_head(text, process): return
		var head := head_element.get_valid_head()
		process.rule = process.grammar.get_command_rule(head)
		process.exe_index = 0
		process.exe_end = process.rule.get_element_count()
	else:
		# 模拟最初环境
		process.rule = process.grammar.get_command_rule(head_element.get_valid_head())
		process.exe_index = exe_element_histories[index]
		process.exe_element = process.rule.get_element(exe_element_histories[index -1]) if index > 0 else null
		process.exe_end = process.rule.get_element_count()
		
		var nearest_element := elements[index]
		var offset := process.offset
		if nearest_element is StringElement:
			offset = nearest_element.string_offset
			process.offset = offset
		
		DictionaryIntKeyT.slice(highlight_data.data, 0, offset + 1)
		elements = elements.slice(0, index)
		exe_element_histories = exe_element_histories.slice(0, index)
		DictionaryIntKeyT.slice(cmd_list, 0, column)
	_do_command_process(text, process)
	_do_command_tail(text, process)

# 处理指令的流程。
func _do_command_process(text : String, process : _CreateProcess) -> void:
	while process.exe_index < process.exe_end:
		var exe_element := process.rule.get_element(process.exe_index)
		
		# 检查可继承。
		if not CommandRule.is_can_exetends(exe_element, process.exe_element):
			process.exe_index += 1
			continue
		
		# 检查是否属于类型。
		var exe_type := exe_element.get_type()
		if not ElementManager.is_inherent_type(exe_type):
			if not ElementManager.try_get_type(text, process.offset).has(exe_type):
				faild_element_idxs.append(process.exe_index)
				process.exe_index += 1
				continue
		
		# 成功执行
		process.exe_element = exe_element
		if _do_function(exe_element, text, process): return
		
		if process.continue_flag:
			process.continue_flag = false
			continue
		if process.break_flag:
			break
		
		# 处理结束。
		if exe_element.has_end(): process.has_end = exe_element.has_end()
		
		# 处理跳转。
		if exe_element.has_goto():
			process.exe_index = exe_element.get_goto()
			continue
		
		process.exe_index += 1
# 处理指令的结尾。
func _do_command_tail(text : String, process : _CreateProcess) -> void:
	var length := text.length()
	if process.has_end:
		if process.offset < length:
			var result := StringElement.create(text, process.offset)
			if not result.is_faild:
				create_error(result.get_valid_start(), "More string \"%s\"." % [result.get_valid_string()])
				return
	else:
		create_error(process.offset , "Cant end.")



