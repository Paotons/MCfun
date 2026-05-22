class_name CommandRule
extends RefCounted
## 指令规则。

## 数据。
var main_data : Array

func set_data(value : Array) -> void:
	main_data = value

## 如果按照 [param idxs] 走，能够结束，返回 [code]true[/code]。
func is_indexs_has_end(idxs : PackedInt32Array) -> bool:
	for i in range(idxs.size() - 1, -1, -1):
		var exe := get_element(idxs[i])
		if not exe.has_end():
			continue
		return exe.is_end()
	return false
## 如果 [param idxs] 走，有附属指令，返回 [code]true[/code]。
func is_indexs_has_subcommand(idxs : PackedInt32Array) -> bool:
	for i in range(idxs.size() - 1, -1, -1):
		var exe := get_element(idxs[i])
		if exe.get_type() == GrammarValue.Type.COMMAND:
			return true
	return false

## 返回元素。
func get_element(idx : int) -> ExeElementRule:
	var exe := ExeElementRule.new()
	exe.data_main = main_data[idx]
	return exe
## 返回元素数量。
func get_element_count() -> int:
	return main_data.size()

## 如果一个 [param a] 可以继承到 [param b] 下，返回 [code]true[/code]。
static func is_can_exetends(a : ExeElementRule, b : ExeElementRule = null) -> bool:
	var ext := a.get_extends()
	if ext == -2: return true
	if b == null: return ext == -1
	var id := b.get_id()
	return ext == id
