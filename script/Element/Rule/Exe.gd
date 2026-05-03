class_name ExeElementRule
extends ElementRule
## 执行元素的规则。
##
## 内涵 [code]Goto,ID,Extends[/code]属性。

#region 元素。
## ID，对应 id。
const META_ID := 10
## 继承，-1 表示继承最开头， -2 继承所有。
const META_EXTENDS := 11
## 可结束。
const META_IS_END := 12
## 跳转。
const META_GOTO := 13
#endregion

## 是否跳转。
func has_goto() -> int:
	return data_main.has(META_GOTO)
## 是否结束。
func has_end() -> bool:
	return data_main.has(META_IS_END)

## 获取 ID。
func get_id() -> int:
	return data_main[META_ID]
## 获取继承。
func get_extends() -> int:
	return data_main[META_EXTENDS]
## 获取跳转。
func get_goto(idx := 0) -> int:
	if not has_goto():
		push_error("Not has goto.")
		return -1
	var goto = data_main[META_GOTO]
	if goto is PackedInt32Array:
		return goto[mini(goto.size() - 1, idx)]
	else:
		return goto

## 是否结束。
func is_end() -> bool:
	return data_main[META_IS_END] if has_end() else false

@warning_ignore("shadowed_variable_base_class")
static func compile(dat : Dictionary, command := []) -> Variant:
	var result = ElementRule.compile(dat)
	if result == null: return null
	var type := result[META_TYPE] as int
	var compiled_data_main := result as Dictionary
	
	match type:
		GrammerValue.Type.OPTION: if _compile_command_item_option(dat, compiled_data_main, command): return null
		GrammerValue.Type.NIL: if _compile_command_item_nil(dat, compiled_data_main, command): return null
		_: if _compile_command_item_default(dat, compiled_data_main, command): return null
	return compiled_data_main

#region 解析。
# 解析选项元素。
static func _compile_command_item_option(from : Dictionary, to : Dictionary, command : Array) -> bool:
	if _compile_meta_value(from, to, "extends", META_EXTENDS, TYPE_INT, true, -2): return true
	if _compile_meta_int(from, to, "id", META_ID, true, _rand_id()): return true
	if _compile_meta_value(from, to, "is_end", META_IS_END, TYPE_BOOL): return true
	
	# goto
	if from.has("goto"):
		var type := typeof(from["goto"])
		if type == TYPE_FLOAT:
			if _compiled_meta_id_to_idx(command, from, to, "goto", META_GOTO): return true
		elif type == TYPE_ARRAY:
			if _compile_meta_ids_to_idxs(command, from, to, "goto", META_GOTO, from.items.size()): return true
	return false
# 解析占位，空元素。
static func _compile_command_item_nil(from : Dictionary, to : Dictionary, command : Array) -> bool:
	if _compile_meta_value(from, to, "extends", META_EXTENDS, TYPE_INT, true, -2): return true
	if _compile_meta_value(from, to, "id", META_ID, TYPE_INT, true, _rand_id()): return true
	if _compile_meta_value(from, to, "is_end", META_IS_END, TYPE_BOOL): return true
	if _compiled_meta_id_to_idx(command, from, to, "goto", META_GOTO): return true
	return false
# 解析默认元素。
static func _compile_command_item_default(from : Dictionary, to : Dictionary, command : Array) -> bool:
	if _compile_meta_value(from, to, "extends", META_EXTENDS, TYPE_INT, true, -2): return true
	if _compile_meta_value(from, to, "id", META_ID, TYPE_INT, true, _rand_id()): return true
	if _compile_meta_value(from, to, "is_end", META_IS_END, TYPE_BOOL): return true
	if _compiled_meta_id_to_idx(command, from, to, "goto", META_GOTO): return true
	return false

# 随机 ID。
static func _rand_id() -> int:
	return randi_range(0xffffff, 0xffffffff)

## [b]Protected:[/b] 解析元素，把 Array(int)id -> Array(int)index。
static func _compile_meta_ids_to_idxs(command : Array, from : Dictionary, to : Dictionary, meta_string : String, meta : int, size := -1, must_has := false) -> bool:
	if from.has(meta_string):
		if not from[meta_string] is Array:
			push_error("Item typed options' meta named %s is %s." % [
				meta_string, type_string(typeof(from[meta_string]))])
			return true
		var gotos : Array = from[meta_string]
		if size != -1 and size != gotos.size():
			push_error("Item typed options' meta named %s' size is %d., but its size should be %d." % [meta_string,
				size, gotos.size()])
			return true
		for i in range(gotos.size()):
			if not gotos[i] is float:
				push_error("Item typed options' meta named %s[%d] is %s." % [meta_string,
					i, type_string(typeof(gotos[i]))])
				return true
		
		var compiled_gotos : PackedInt32Array
		for goto in gotos:
			var index : int = _get_command_item_index(command, goto)
			if index == -1:
				push_error("Cant find id named %d." % [goto])
				return true
			compiled_gotos.append(index)
		to[meta] = compiled_gotos
		return false
	elif must_has:
		push_error("Item must has meta named %s." % [meta_string])
		return true
	else:
		return false
## [b]Protected:[/b] 解析元素，把 id -> idx。
static func _compiled_meta_id_to_idx(command : Array, from : Dictionary, to : Dictionary, meta_string : String, meta : int, must_has := false) -> bool:
	if from.has(meta_string):
		if from[meta_string] is float:
			var index : int = _get_command_item_index(command, from[meta_string])
			if index == -1:
				push_error("Cant find id named %d." % [from[meta_string]])
				return true
			to[meta] = index
			return false
		else:
			push_error("Meta named %s is %s." % [meta_string, type_string(typeof(from[meta_string]))])
			return true
	elif must_has:
		push_error("Item must has meta named %s." % [meta_string])
		return true
	else:
		return false

# 获取指令选项的 ID 条目的序列。
static func _get_command_item_index(command : Array, id : int) -> int:
	for i in command.size():
		var param : Dictionary = command[i]
		if not param.has("id"):
			continue
		if param.id == id:
			return i
	return -1
#endregion

