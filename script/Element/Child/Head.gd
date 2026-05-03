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

## 获取高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_key_word}, get_valid_end() : {"color" : edit.color_default}}

## 创建一个。
static func create(text : String, offset : int) -> HeadElement:
	return WordElement._create_word_element(HeadElement.new(), text, offset)

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
