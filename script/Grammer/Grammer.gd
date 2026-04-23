class_name Grammer
extends Resource
## 语法。
##
## 含有多个可执行元素。

# 解析后的语法规则，给机器看的。
var _grammer_compiled : Dictionary

## 获取指令的一个项。
func get_item(head : String, idx : int) -> ExeElementRule:
	if not has_head(head):
		push_error("Not has head named \"%s\"." % [head])
		return null
	var command : Array = _grammer_compiled[head]
	if command.size() <= absi(idx):
		push_error("Command's size is %d, but get %d." % [command.size(), idx])
		return null
	var item := ExeElementRule.new()
	item.data_main = command[idx]
	return item
## 获取指令项的数量。
func get_item_count(head : String) -> int:
	if not has_head(head):
		push_error("Not has head named \"%s\"." % [head])
		return -1
	return _grammer_compiled[head].size()
## 获取一条指令中为 ID 项的序列。
func get_item_index(head : String, id : int) -> int:
	if not has_head(head):
		return -1
	var command : Array = _grammer_compiled[head]
	var i := 0
	for item : Dictionary in command:
		if item[ExeElementRule.META_ID] == id:
			return i
		i += 1
	return -1
## 获取从某个序列开始经过的历史序列。
func get_item_histories(head : String, start : int, exclude_nil := false) -> PackedInt32Array:
	if not has_head(head):
		push_error("Not has head \"%s\"" % [head])
		return []
	var command : Array = _grammer_compiled[head]
	var i := start
	var size := command.size()
	var histories : PackedInt32Array
	var result : PackedInt32Array
	while i < size:
		var item : Dictionary = command[i]
		var ext : int = item[ExeElementRule.META_EXTENDS]
		var id : int = item[ExeElementRule.META_ID]
		var type : GrammerValue.Type = item[ExeElementRule.META_TYPE]
		if ext >= 0:
			if histories[histories.size() - 1] != ext:
				i += 1
				continue
		else:
			if ext == -1:
				if not histories.is_empty():
					i += 1
					continue
		
		if type == GrammerValue.Type.NIL:
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

## 包含指令。
func has_head(head : String) -> bool:
	return _grammer_compiled.has(head)
## 获取指令的数量。
func get_command_count() -> int:
	return _grammer_compiled.size()
## 获取指令规则。
func get_command_rule(head : String) -> CommandRule:
	if not has_head(head): return null
	var rule := CommandRule.new()
	rule.data = _grammer_compiled[head]
	return rule
## 获取所有指令头。
func get_heads() -> PackedStringArray:
	return _grammer_compiled.keys()

## 解析语法。
func compile(grammer : Dictionary) -> void:
	var grammer_compiled : Dictionary
	for head in grammer:
		var command = grammer[head]
		var command_compiled : Variant = _compile_command(command)
		if command_compiled != null:
			grammer_compiled[head] = command_compiled
		else:
			push_error("The command named %s is null." % [head])
	_grammer_compiled = grammer_compiled
	print_rich("[color=#090]", grammer_compiled)
# 解析指令。
static func _compile_command(command : Array) -> Variant:
	var command_compiled : Array
	for i in range(command.size()):
		if not command[i] is Dictionary:
			return null
		var item := command[i] as Dictionary
		var result : Variant = ExeElementRule.compile(item, command)
		if result != null and result is Dictionary:
			command_compiled.append(result)
		else:
			return null
	return command_compiled
