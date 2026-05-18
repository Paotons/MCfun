class_name CommandElement
extends StringElement
## 整条指令。

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

## [b]frient [CommandElementCreater]:[/b] 如果是 [code]true[/code]，则表示有子指令。
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
	var process :=CommandElementCreaterProcess.new()
	
	process.edit = EditManager.get_edit()
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = line
	
	process.offset = offset
	
	element.line_id = process.edit.get_line_id(line)
	
	var creater := CommandElementCreater.new()
	creater.command = element
	creater.run_from_empty(text, process)
	return element
## [param column] 发生更新。
func update(text : String, column : int) -> CommandElement:
	var offset := string_offset
	var edit := EditManager.get_edit()
	# 初始化。
	faild_element_idxs.clear()
	errors.clear()
	string = text.substr(offset)
	
	# 进程。
	var process :=CommandElementCreaterProcess.new()
	
	process.edit = edit
	process.grammar = EditManager.get_grammar_process()
	process.law = EditManager.get_grammar_law()
	process.entry = EditManager.get_grammar_entry()
	process.line = edit.get_line_index(line_id)
	
	process.offset = offset
	
	var creater := CommandElementCreater.new()
	creater.command = self
	return creater.run_from_column(text, process, column)

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
## 如果序列处于有效开头，返回 [code]true[/code]。
func is_column_outside_valid(column : int) -> bool:
	return column <= valid_start
## 如果序列处于头部位置，返回 [code]true[/code]。
func is_column_at_head(column : int) -> bool:
	if column <= string_offset: return false
	
	if is_empty(): return true
	return column <= get_valid_start() + head_string.length()
## 如果处于序列处于尾部位置，返回 [code]true[/code]。
func is_column_at_end(column : int) -> bool:
	if elements.is_empty():
		return column > valid_start + get_head_string().length()
	var element : Element
	for i in range(1, elements.size() + 1):
		element = elements[elements.size() - i]
		if element != null: break
	return not element is CommandElement and column > element.get_valid_end()
## 返回某个位置在所处的元素序列，返回 [code]-1[/code] 表示非语法上的位置。
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

