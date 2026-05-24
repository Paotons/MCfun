@abstract
class_name BaseStringElement
extends Element
## 基类字符串元素。
##
## 抽象类，你不应该实例化。

## 获取到的字符串。
var string : String
## 字符串偏移。
var string_offset := -1
## 有效开头。
var valid_start := -1

@warning_ignore("unused_parameter")
## 虚函数，用于创建元素。
static func create(text : String, offset : int) -> BaseStringElement:
	return

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


