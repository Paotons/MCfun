class_name StringElement
extends Element
## 字符串元素。
##
## 几乎所有元素的基类。

## 字符串分割符。
const STRING_SPLIT := " \t"

## 获取到的字符串。
var string : String
## 字符串偏移。
var string_offset := -1
## 有效开头。
var valid_start := -1

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_string}, get_valid_end() : {"color" : edit.color_default}}
func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data : FunctionCompletionData = ElementRuleCMD.execute_completion(column, rule, command) if rule.has_cmd() else FunctionCompletionData.new()
	data.hint_string = "<%s : string>" % [rule.get_description()]
	return data
static func get_precast_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data : FunctionCompletionData = ElementRuleCMD.execute_completion(column, rule, command) if rule.has_cmd() else FunctionCompletionData.new()
	data.hint_string = "<%s : string>" % [rule.get_description()]
	return data

static var _string_searched_regex := RegEx.create_from_string(r"^\p{Zs}*(?<string>[^\p{Zs}]+)")
## 可作为虚函数，创建。
static func create(text : String, offset : int) -> StringElement:
	return _create_string_element(StringElement.new(), text, offset)
## 这个类应该是 Protected，可用于创建特定类型的结果。
static func _create_string_element(element : StringElement, text : String, offset : int) -> StringElement:
	element.string_offset = offset
	
	var result := _string_searched_regex.search(text.substr(offset))
	if result != null:
		element.string = result.get_string()
		element.valid_start = result.get_start("string")
		element.is_faild = false
		return element
	else:
		element.create_error(offset, "Not find any string.")
		return element

## 获取有效字符起点。
func get_valid_start() -> int:
	is_faild_assert()
	return -1 if string_offset == -1 or valid_start == -1 else valid_start + string_offset
## 获取有效字符终点。
func get_valid_end() -> int:
	is_faild_assert()
	return -1 if string_offset == -1 else string.length() + string_offset
## 获取有效字符。
func get_valid_string() -> String:
	is_faild_assert()
	return string.substr(valid_start)
## 如果序列在该字符串内，返回 [code]true[/code]。
func has_column(column : int) -> bool:
	is_faild_assert()
	column -= string_offset
	return 0 < column and column <= string.length()

## 获取最近的字符串的开头。
static func get_nearest_string_start(text : String, offset : int) -> int:
	var start := offset
	var length := text.length()
	while start < length:
		var chr := text[start]
		if chr == " ":
			start += 1
			continue
		else:
			return start
	return -1
## 如果最近的字符串以指定字符开始，返回 [code]true[/code]。
static func is_nearest_string_begin_with(text : String, offset : int, with : String) -> bool:
	if with.is_empty(): return true
	var clip_length := with.length()
	var begin := get_nearest_string_start(text, offset)
	var with_string := text.substr(begin, clip_length if begin + clip_length < text.length() else 0)
	return not with_string.is_empty() and with_string == with

static func _is_valid_chr(chr : int) -> bool:
	return chr !=32 and chr != 9

