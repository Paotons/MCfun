class_name BaseCommandElement
extends BaseStringElement
## 指令的基类。

## 指令类型。
var command_type : int = CommandElementManager.CommandType.EMPTY

## [b]frient [CommandElementCreater]:[/b] 指令列表。
var _cmd_list : CMDList
## [b]frient [CommandElementCreater]:[/b] 指令中的各种元素。
var _elements : Array[Element]
## [b]frient [CommandElementCreater]:[/b] 高亮数据。
var _highlight_data : HightLightData

## [b]frient [CommandElementCreater]:[/b] 如果是 [code]true[/code]，则表示有子指令。
var _has_child_element := false
## [b]Protected:[/b] 行的 ID。
var _line_id := -1

func get_highlight(_edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return _highlight_data.data if _highlight_data != null else Dictionary({}, TYPE_INT,&"", null, TYPE_DICTIONARY, &"", null)
static func create(text : String, offset : int, line := -1) -> BaseCommandElement:
	var i := StrT.find_unempty(text, offset)
	var chr := text[-1] if i == -1 else text[i]
	
	match chr:
		" ":
			var command := BaseCommandElement.new()
			command.string_offset = offset
			command._line_id = EditManager.get_edit().get_line_id(line)
			command.command_type = CommandElementManager.CommandType.EMPTY
			return command
		"?":
			return HelpCommandElement.create(text, offset, line)
		"#":
			return AnnotationCommandElement.create(text, offset, line)
		"&":
			return NativeCommandElement.create(text, offset, line)
		"@":
			return CommentCommandElement.create(text, offset, line)
		_:
			return CommandElement.create(text, offset, line)
## 虚函数，从 [param column] 处更新。
@warning_ignore("unused_parameter")
func _update(text : String, column : int) -> BaseCommandElement:
	return create(text, string_offset, get_line_index())
## 更新指令。
func update(text : String, column : int) -> BaseCommandElement:
	return _update(text, column)
## 获取这条指令所在的行。
func get_line_index() -> int:
	return -1 if _line_id == -1 else EditManager.get_edit().get_line_index(_line_id)

## 如果是空指令，返回 [code]true[/code]。
func is_empty() -> bool:
	return command_type == CommandElementManager.CommandType.EMPTY

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

## 返回这条指令的命名列表指定类型。
func get_cmd_list(type : String, column := -1) -> PackedStringArray:
	var result : PackedStringArray
	if _has_child_element:
		for child in get_child_commands(true):
			result.append_array(child.get_cmd_list(type, column))
	
	if _cmd_list == null:
		return result
	
	result.append_array(_cmd_list.get_list(type, column))
	return result
## 添加指令列表。
func add_cmd_list(type : String, value : String, column := 0) -> void:
	if _cmd_list == null:
		_cmd_list = CMDList.new()
	_cmd_list.add_mumber(type, value, column)
## 清空指令列表。
func clear_cmd_list() -> void:
	_cmd_list = null

## 返回可用的元素数量。
func get_valid_element_count() -> int:
	var res := 0
	for element in _elements:
		res += 1 if element != null and not element.is_faild else 0
	return res
## 返回可用元素的序列。
func get_valid_element_index(idx : int) -> int:
	var j := 0
	for i in _elements.size():
		var element := _elements[i]
		if element == null or element.is_faild:
			continue
		j += 1
		if j == idx:
			return i
	return -1

## 设置行数。
func set_line(line : int) -> void:
	var edit := EditManager.get_edit()
	_line_id = edit.get_line_id(line)

