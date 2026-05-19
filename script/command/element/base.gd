@abstract
class_name BaseCommandElement
extends StringElement
## 指令的基类。
##
## 抽象类，你不应该实例化。

## 指令类型。
enum CommandType {
	## 最开始，根部。
	ROOT,
	## 直接替代原来的父指令，直达最后，类型于 execute run 分支一样。
	REPLACE,
}

## 指令类型。
var command_type := CommandType.REPLACE

## [b]frient [CommandElementCreater], [ElementRuleCMD]:[/b] 储存运行时变量的列表。
var _cmd_list : Dictionary[int, Dictionary]
## [b]frient [CommandElementCreater]:[/b] 指令中的各种元素。
var _elements : Array[Element]
## [b]frient [CommandElementCreater]:[/b] 高亮数据。
var _highlight_data : HightLightData

## [b]frient [CommandElementCreater]:[/b] 如果是 [code]true[/code]，则表示有子指令。
var _has_child_element := false
## [b]Protected:[/b] 行的 ID。
var _line_id := -1

func get_highlight(_edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return _highlight_data.data
## 获取这条指令所在的行。
func get_line_index() -> int:
	return -1 if _line_id == -1 else EditManager.get_edit().get_line_index(_line_id)

## 如果这条指令有子指令，返回 [code]true[/code]。
func has_child_command() -> bool:
	return _has_child_element
## 获取子类指令元素。
func get_child_commands(deep := false) -> Array[BaseCommandElement]:
	if not _has_child_element:
		return []
	
	var result : Array[BaseCommandElement]
	for element in _elements:
		if element is CommandElement:
			result.append(element)
			if deep:
				result.append_array(element.get_child_commands(true))
	return result

#region 元素。
## 获取元素。
func get_element(idx : int) -> Element:
	return _elements[idx]
## 获取元素数量。
func get_element_count() -> int:
	return _elements.size()
#endregion

## 获取这条指令的命名列表。
func get_cmd_list(id : int, column := -1) -> PackedStringArray:
	var result : PackedStringArray
	if _has_child_element:
		for child in get_child_commands(true):
			result.append_array(child.get_cmd_list(id, column))
	
	if not _cmd_list.has(id): return result
	column = 0xFFFFFFFF if column == -1 else column
	var list : Dictionary = _cmd_list[id]
	for key : int in list:
		if key < column: result.append(list[key])
	return result


