class_name CommandElementCreater
extends RefCounted
## 指令元素创建者。
##
## 用于创建 [CommandElement] 的。

## 指令元素。
var command : CommandElement

# 获取失败的列表。
func _get_failds() -> PackedInt32Array:
	return command.faild_element_idxs
# 获取高亮数据。
func _get_hl_data() -> HightLightData:
	return command.highlight_data
## 为元素加入历史。
func add_history(idx : int, ele : Element = null) -> void:
	command.add_history(idx, ele)
## 为元素创建一个错误。
func create_error(column : int, string : String, type := ElementError.Type.NOTFIND) -> void:
	command.create_error(column, string, type)

## 从零开始处理指令。
func run_from_empty(text : String, process : CommandElementCreaterProcess) -> void:
	if _do_head(text, process):
		return
	
	var head := command.head_element.get_valid_head()
	process.rule = process.grammar.get_command_rule(head)
	process.exe_index = 0
	process.exe_end = process.rule.get_element_count()
	_do_command_process(text, process)
	_do_command_tail(text, process)
## 从一定位置开始处理指令。
func run_from_column(text : String, process : CommandElementCreaterProcess, column := 0) -> CommandElement:
	var index : int = command.get_column_map_index(column) if not command.is_column_at_end(column) else command.exe_element_histories.size() - 1
	
	if index < 1: # 相当于重新生成。
		return CommandElement.create(text, process.offset, command.get_line_index())
	else:
		if command.elements[index] is CommandElement:
			var element := command.elements[index] as CommandElement
			if element.is_valid_head() and element.string_offset + 2 < column:
				return _run_from_column_suncommand(text, column, index)
		return _run_from_column_normal(text, process, column, index - 1)

func _run_from_column_suncommand(text : String, column := 0, index := 0) -> CommandElement:
	var element := command.elements[index] as CommandElement
	var offset := element.string_offset
	
	DictionaryIntKeyT.slice(_get_hl_data().data, 0, offset + 1)
	DictionaryIntKeyT.slice(command.cmd_list, 0, column)
	
	var new_element := element.update(text, column)
	command.elements[index] = new_element
	_get_hl_data().merge(new_element.get_highlight(EditManager.get_edit()))
	command.errors.append_array(new_element.errors)
	return command
func _run_from_column_normal(text : String, process : CommandElementCreaterProcess, column := 0, index := 0) -> CommandElement:
	# 模拟最初环境
	process.rule = process.grammar.get_command_rule(command.head_element.get_valid_head())
	process.exe_index = command.exe_element_histories[index]
	process.exe_element = process.rule.get_element(command.exe_element_histories[index -1]) if index > 0 else null
	process.exe_end = process.rule.get_element_count()
	
	var nearest_element := command.elements[index]
	var offset := process.offset
	if nearest_element is StringElement:
		offset = nearest_element.string_offset
		process.offset = offset
	
	DictionaryIntKeyT.slice(_get_hl_data().data, 0, offset + 1)
	command.elements = command.elements.slice(0, index)
	command.exe_element_histories = command.exe_element_histories.slice(0, index)
	DictionaryIntKeyT.slice(command.cmd_list, 0, column)
	
	process.has_end = process.rule.is_indexs_has_end(command.exe_element_histories)
	_do_command_process(text, process)
	_do_command_tail(text, process)
	return command

# 处理函数。
func _do_function(element : ExeElementRule, text : String, process : CommandElementCreaterProcess) -> bool:
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
	breakpoint # 正常情况，不会到这
	return true

#region 处理。
# 处理开头。
func _do_head(text : String, process : CommandElementCreaterProcess) -> bool:
	var result := HeadElement.create(text, process.offset) as HeadElement
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	command.is_faild = false
	command.valid_start = result.get_valid_start() - process.offset
	
	var head := result.get_valid_string()
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	command.head_element = result
	command.head_string = head
	
	if not process.grammar.has_head(head):
		create_error(result.get_valid_start(), "Unfind command \"%s\"." % [head])
		return true
	
	process.offset = result.get_valid_end()
	return false

# 处理空值，占位。
func _do_nil(_text : String, process : CommandElementCreaterProcess) -> bool:
	var items := process.exe_element.get_items()
	if items.is_empty(): return false
	for item in items:
		match item:
			"cmp":
				_get_failds().clear()
	add_history(process.exe_index)
	return false

# 默认处理。
func _do_default(text : String, process : CommandElementCreaterProcess) -> bool:
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
		_get_failds().append(process.exe_index)
		# Err
		if not process.has_end:
			for err in element.errors: create_error(err.column, err.string)
		return true
	for err in element.errors: create_error(err.column, err.string)
	
	# CMD
	if exe_element.has_cmd():
		ElementRuleCMD.execute(element, exe_element, element, ElementRuleCMD.ModeFilter.LIST)
	
	_get_hl_data().merge(element.get_highlight(process.edit))
	
	process.offset = element.get_valid_end()
	add_history(process.exe_index, element)
	return false

# 处理选项。
func _do_option(text : String, process : CommandElementCreaterProcess) -> bool:
	var exe := process.exe_element
	var result := OptionElement.create(text, process.offset, exe)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild:
		_get_failds().append(process.exe_index)
		return true
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	
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
		_get_failds().append(process.exe_index)
	
		process.exe_index += 1
		if exe.has_end():
			process.has_end = exe.is_end()
		process.continue_flag = true
		return true
# 处理坐标。
func _do_coords(text : String, process : CommandElementCreaterProcess) -> bool:
	var result := CoordsElement.create(text, process.offset)
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	
	add_history(process.exe_index, result)
	process.offset = result.get_valid_end()
	
	return result.get_valid_size() != 3
# 处理目标选择器。
func _do_selector(text : String, process : CommandElementCreaterProcess) -> bool:
	var result := SelectorElement.create(text, process.offset)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	
	if result.has_body():
		var backet := result.get_body_element()
		for err in backet.errors:
			create_error(err.column, "Body has error \"%s\"." % [err.string])
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false
# 处理空间物品。
func _do_spaceitem(text : String, process : CommandElementCreaterProcess) -> bool:
	var result := SpaceItemElement.create(text, process.offset)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	if not result.has_value():
		_get_failds().append(process.exe_index)
		return true
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false

#region 处理字典，大括号包括的。
# 入口
func _do_dictionary(text : String, process : CommandElementCreaterProcess) -> bool:
	var rule := process.exe_element.get_rule()
	if rule == null:
		push_warning("Not find rule \"%s\"." % [process.exe_element.get_rule_name()])
		return _do_dictionary_default(text, process)
	
	match rule.get_type():
		GrammarRule.RuleType.COLON_PARAM_BACKET: return _do_dictionary_colon_param(text, process, rule)
	push_error("Rule is nul type.")
	return true

# 处理冒号参数。
func _do_dictionary_colon_param(text : String, process : CommandElementCreaterProcess , rule : GrammarRule) -> bool:
	var result := ColonParamBacketElement.create(text, process.offset, "{", "}", rule)
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return true
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	
	process.offset = result.get_valid_end()
	add_history(process.exe_index, result)
	return false
# 默认处理。
func _do_dictionary_default(text : String, process : CommandElementCreaterProcess) -> bool:
	var sult := BacketElement.create(text, process.offset, "{", "}")
	
	for err in sult.errors: create_error(err.column, err.string)
	if sult.is_faild: return true
	
	process.offset = sult.get_valid_end()
	add_history(process.exe_index, sult)
	return false
#endregion

# 处理数组，中括号包括的，如果是目标选择器，应该就用针对性的目标选择器。
func _do_array(text : String, process : CommandElementCreaterProcess) -> bool:
	var sult := BacketElement.create(text, process.offset, "[", "]")
	
	for err in sult.errors: create_error(err.column, err.string)
	if sult.is_faild: return true
	
	process.offset = sult.get_valid_end()
	add_history(process.exe_index, sult)
	return false
# 处理指令中的附属指令。
func _do_subcommand(text : String, process : CommandElementCreaterProcess) -> bool:
	if process.offset == text.length():
		create_error(process.offset, "Not find command.")
		return true
	
	var result := CommandElement.create(text, process.offset, process.line)
	
	if result.is_empty(): create_error(process.offset, "Not find command.")
	if result.has_error():
		_get_failds().append(process.exe_index)
		for err in result.errors: create_error(process.offset + err.column, err.string)
	
	command._has_child_element = true
	_get_hl_data().merge(result.get_highlight(process.edit))
	add_history(process.exe_index, result)
	return true
#endregion

# 处理指令的流程。
func _do_command_process(text : String, process : CommandElementCreaterProcess) -> void:
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
				_get_failds().append(process.exe_index)
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
func _do_command_tail(text : String, process : CommandElementCreaterProcess) -> void:
	var length := text.length()
	if process.has_end:
		if process.offset < length:
			var result := StringElement.create(text, process.offset)
			if not result.is_faild:
				create_error(result.get_valid_start(), "More string \"%s\"." % [result.get_valid_string()])
				return
	else:
		create_error(process.offset , "Cant end.")

