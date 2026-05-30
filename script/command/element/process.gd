@abstract
class_name ProcessCommandElement
extends BaseCommandElement
## 进程指令。
##
## 依赖进程完成的指令。抽象类，你不应该实例化。

## 失败的元素序列，即期望列表。
var faild_element_idxs : PackedInt32Array
## 经过的执行元素序列。
var exe_element_histories : PackedInt32Array

## 开头元素。
var head_element : HeadElement
## 头。
var head_string : String

## 虚函数，返回进程。
@abstract func _get_process() -> GrammarProcess;
## 获取进程。
func get_process() -> GrammarProcess:
	return _get_process()

## 获取头。
func get_head_string() -> String:
	return head_string
## 如果是可用的头，返回 [code]true[/code]。
func is_valid_head() -> bool:
	return _get_process().has_head(head_string)

## 返回历史 ID。
func get_history_ids() -> PackedInt32Array:
	var command := _get_process().get_command_rule(head_string)
	var res : PackedInt32Array
	for idx in exe_element_histories:
		res.append(command.get_element(idx).get_id())
	return res
## 返回指定元素序列在进程中的序列。
func get_history(idx : int) -> int:
	return exe_element_histories[idx]
## 返回进程中的序列在历史中的序列。
func find_history(idx : int) -> int:
	return exe_element_histories.find(idx)

#region 序列
## 如果序列前面一个数据是完整的目标选择器头，返回 [code]true[/code]。
func is_column_near_selector_head(column : int) -> bool:
	var size := _elements.size()
	for i in size:
		var element := _elements[i]
		if element is SelectorElement:
			if element.has_body():
				continue
			if i + 1 >= size:
				return element.is_selector()
			var element2 := _elements[i + 1]
			if element2 is SelectorElement:
				return column >= element2.get_head_end() and column < element2.get_valid_start() and element2.is_selector()
	return false
## 如果序列处于有效开头，返回 [code]true[/code]。
func is_column_outside_valid(column : int) -> bool:
	return column <= valid_start
## 如果序列处于头部位置，返回 [code]true[/code]。
func is_column_at_head(column : int) -> bool:
	if is_empty(): return true
	return get_valid_start() <= column - 1 and column <= get_valid_start() + head_string.length()
## 如果处于序列处于尾部位置，返回 [code]true[/code]。
func is_column_at_end(column : int) -> bool:
	if _elements.is_empty():
		return column > valid_start + get_head_string().length()
	var element : Element
	for i in range(1, _elements.size() + 1):
		element = _elements[_elements.size() - i]
		if element != null: break
	return element == null or (not element is BaseCommandElement and column > element.get_valid_end())
## 返回某个位置在所处的元素序列，返回 [code]-1[/code] 表示非语法上的位置。
func get_column_map_index(column : int) -> int:
	for i in _elements.size():
		var element := _elements[i]
		if element is BaseCommandElement:
			if element.command_type & CommandElementManager.CommandType.REPLACE != 0:
				if column > element.string_offset:
					return i
		elif element is BaseStringElement:
			if element.get_valid_start() < column and column <= element.get_valid_end():
				return i
	return -1
#endregion

#region 元素
## 获取可执行元素规则。
func get_exe_element(idx : int) -> ExeElementRule:
	var grammar := _get_process()
	if not grammar.has_head(head_string):
		push_error("Head \"%s\" is unvalid." % [head_string])
		return null
	return grammar.get_item(head_string, idx)

## 返回失败的执行元素。
func get_faild_element(idx : int) -> ExeElementRule:
	return _get_process().get_item(head_string, faild_element_idxs[idx])
## 返回失败的执行元素的数量。
func get_faild_element_count() -> int:
	return faild_element_idxs.size()
#endregion

## [b]Protected:[/b] 如果 [param column] 位于指令的末尾，才会正确返回补全内容。
func _get_code_completion_next(column : int) -> FunctionCompletionData:
	var data_main := FunctionCompletionData.new()
	
	# 非法头部。
	if not is_valid_head():
		return null
	
	# 上一个是目标选择器
	if is_column_near_selector_head(column):
		data_main.supple()
		data_main.add_data(FunctionCompletionData.create_backet_data(GrammarValue.Type.ARRAY))
	
	# 补全下一个元素
	for i in get_faild_element_count():
		var faild_exe := get_faild_element(i)
		
		var data := FunctionCompletionData.new()
		var type := faild_exe.get_type()
		match type:
			GrammarValue.Type.DICTIONARY, GrammarValue.Type.ARRAY, GrammarValue.Type.QUOTATION:
				data = FunctionCompletionData.create_backet_data(type)
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

