class_name CommandRule
extends RefCounted
## 指令规则。

## 数据。
var data : Array

## 获取元素。
func get_element(idx : int) -> ExeElementRule:
	var exe := ExeElementRule.new()
	exe.data_main = data[idx]
	return exe
## 获取元素数量。
func get_element_count() -> int:
	return data.size()

## 如果一个 [param a] 可以继承到 [param b] 下，返回 [code]true[/code]。
static func is_can_exetends(a : ExeElementRule, b : ExeElementRule = null) -> bool:
	var ext := a.get_extends()
	if ext == -2: return true
	if b == null: return ext == -1
	var id := b.get_id()
	return ext == id
