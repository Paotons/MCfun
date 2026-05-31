class_name GrammarProcess
extends Resource
## 语法。
##
## 含有多个可执行元素。

const _COMMAND_DESCRIPTION := 0
const _COMMAND_DATA := 1

enum ProcessMeta {
	# HACK 并无用处。
	## 描述。
	DESCRIPTION,
	## 数据。
	DATA,
	## 元列表类型。
	CMD_LIST_TYPES,
}

## 解析后的语法规则，给机器看的。
var main_data : Dictionary
## 元素列表类型。
var _cmd_list_types : PackedStringArray

#region 缓存。
# 指令的队列。
var _queue_heads : PackedStringArray
var _head_completion_data : FunctionCompletionData
#endregion

## 设置数据。
func set_data(data : Dictionary) -> void:
	main_data = data[ProcessMeta.DATA]
	_cmd_list_types = data[ProcessMeta.CMD_LIST_TYPES]
	_queue_heads = PackedStringArray(main_data.keys())
## 获取数据。
func get_data() -> Dictionary:
	return {
		ProcessMeta.DATA : main_data,
		ProcessMeta.CMD_LIST_TYPES : _cmd_list_types,
	}
## 返回指令头的补全数据。
func get_head_completion_data() -> FunctionCompletionData:
	if _head_completion_data != null:
		return _head_completion_data
	
	var data := FunctionCompletionData.new()
	data.insert_texts.append_array(get_heads())
	data.display_texts.append_array(get_descriptions())
	data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
	_head_completion_data = data
	
	return _head_completion_data

## 返回指令的一个项。
func get_item(head : String, idx : int) -> ExeElementRule:
	if not has_head(head):
		push_error("Not has head named \"%s\"." % [head])
		return null
	var command := _get_command_data(head)
	if command.size() <= absi(idx):
		push_error("Command's size is %d, but get %d." % [command.size(), idx])
		return null
	var item := ExeElementRule.new()
	item.data_main = command[idx]
	return item
## 返回指令项的数量。
func get_item_count(head : String) -> int:
	if not has_head(head):
		push_error("Not has head named \"%s\"." % [head])
		return -1
	return _get_command_data(head).size()
## 返回一条指令中为 ID 项的序列。
func get_item_index(head : String, id : int) -> int:
	if not has_head(head):
		return -1
	var command := _get_command_data(head)
	var i := 0
	for item : Dictionary in command:
		if item[ExeElementRule.META_ID] == id:
			return i
		i += 1
	return -1
## 返回从某个序列开始经过的历史序列。
func get_item_histories(head : String, start : int, exclude_nil := false) -> PackedInt32Array:
	if not has_head(head):
		push_error("Not has head \"%s\"" % [head])
		return []
	var command := _get_command_data(head)
	var i := start
	var size := command.size()
	var histories : PackedInt32Array
	var result : PackedInt32Array
	while i < size:
		var item : Dictionary = command[i]
		var ext : int = item[ExeElementRule.META_EXTENDS]
		var id : int = item[ExeElementRule.META_ID]
		var type : GrammarValue.Type = item[ExeElementRule.META_TYPE]
		if ext >= 0:
			if histories[histories.size() - 1] != ext:
				i += 1
				continue
		else:
			if ext == -1:
				if not histories.is_empty():
					i += 1
					continue
		
		if type == GrammarValue.Type.NIL:
			if not exclude_nil:
				result.append(i)
			histories.append(id)
			if item.has(ExeElementRule.META_ITEMS):
				var items : Array = item[ExeElementRule.META_ITEMS]
				if items.has("cmp"):
					result.clear()
			if item.has(ExeElementRule.META_GOTO):
				i = item[ExeElementRule.META_GOTO]
			else:
				i += 1
			continue
		else:
			result.append(i)
			histories.append(id)
			i += 1
	return result

## 返回指定指令的描述。
func get_command_description(head : String) -> String:
	if not has_head(head):
		return ""
	return _get_command_description(head)
## 如果有这个头，返回 [code]true[/code]。
func has_head(head : String) -> bool:
	return main_data.has(head)
## 返回指令的数量。
func get_command_count() -> int:
	return main_data.size()
## 返回指令规则。
func get_command_rule(head : String) -> CommandRule:
	if not has_head(head): return null
	var rule := CommandRule.new()
	rule.set_data(_get_command_data(head))
	return rule
## 返回所有指令头。
func get_heads() -> PackedStringArray:
	return _queue_heads
## 返回所有指令的描述。
func get_descriptions() -> PackedStringArray:
	var res : PackedStringArray
	for head in _queue_heads:
		res.append(_get_command_description(head))
	return res
## 返回元素列表类型。
func get_cmd_list_tyes() -> PackedStringArray:
	return _cmd_list_types

# 返回指令的数据。
func _get_command_data(head : String) -> Array:
	return main_data[head][_COMMAND_DATA]
# 返回指令的描述。
func _get_command_description(head : String) -> String:
	return main_data[head][_COMMAND_DESCRIPTION]
