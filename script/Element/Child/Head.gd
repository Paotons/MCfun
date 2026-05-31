class_name HeadElement
extends WordElement
## 获取到的头部数据。

## 开头模式。
enum BeginMode {
	## 直接开头。
	DIRECT,
	## 缩进开头。
	TAB,
	## 斜杠开头。
	SLASH,
	## 函数开头。
	FUNCTION,
	## 错误开头。
	ERROR,
}

## 指令类型。
var command_type : int

## 获取高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : _get_highlight_color(edit)}, get_valid_end() : {"color" : edit.color_default}}

## 创建一个。
static func create(text : String, offset : int, type := 0) -> HeadElement:
	var element := WordElement._create_word_element(HeadElement.new(), text, offset) as WordElement
	element.command_type = type
	return element

## 获取开头模式。
func get_begin_mode() -> BeginMode:
	if is_faild:
		return BeginMode.ERROR
	
	if string.begins_with("/"):
		return BeginMode.SLASH
	if valid_start == 0:
		return BeginMode.DIRECT
	if string.begins_with("\t"):
		return BeginMode.TAB
	return BeginMode.ERROR

## 获取头部字符串。
func get_valid_head() -> String:
	is_faild_assert()
	match get_begin_mode():
		BeginMode.DIRECT:
			return get_valid_string()
		BeginMode.TAB:
			return get_valid_string()
		BeginMode.SLASH:
			return get_valid_string().substr(1)
		_:
			return get_valid_string()

# 返回高亮颜色。
func _get_highlight_color(edit : FunctionEdit) -> Color:
	if command_type & CommandElementManager.CommandType.NORMAL != 0:
		return edit.color_normal_command_head
	elif command_type & CommandElementManager.CommandType.NATIVE != 0:
		return edit.color_native_command_head
	elif command_type & CommandElementManager.CommandType.COMMENT != 0:
		return edit.color_comment_command_head
	else:
		return edit.color_default
