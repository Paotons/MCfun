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
