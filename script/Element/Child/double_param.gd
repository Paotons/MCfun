@abstract class_name DoubleParamElement
extends StringElement
## 有两个参数的元素。
##
## 这两个参数，可通过键 [code]key[/code] 和值 [code]value[/code] 来访问。抽象类，你不应该实例化这个类。

## 键的开始
var key_start := -1
## 键的结束。
var key_end := -1
## 值的开始。
var value_start := -1
## 值的结束。
var value_end := -1
## 键的结果。
var key_element : StringElement
## 值的结果。
var value_element : StringElement
## 键的预期类型。
var key_type := -1
## 值的预期类型。
var value_type := -1

## 如果有键，返回 [code]true[/code]。
func has_key() -> bool:
	is_faild_assert()
	return key_start != -1
## 如果有值，返回 [code]true[/code]。
func has_value() -> bool:
	is_faild_assert()
	return value_start != -1
## 获取键的字符串。
func get_key_string() -> String:
	is_faild_assert()
	return "" if key_start == -1 else string.substr(key_start, -1 if key_end == -1 else key_end - key_start)
## 获取键的字符串。
func get_value_string() -> String:
	is_faild_assert()
	return "" if value_start == -1 else string.substr(value_start, -1 if value_end == -1 else value_end - value_start)
## 获取键的开头。
func get_key_start() -> int:
	is_faild_assert()
	return -1 if key_start == -1 else string_offset + key_start
## 获取键的结尾。
func get_key_end() -> int:
	is_faild_assert()
	return string_offset + string.length() if key_end == -1 else string_offset + key_end
## 获取值的开头。
func get_value_start() -> int:
	is_faild_assert()
	return -1 if value_start == -1 else string_offset + value_start
## 获取值的结尾。
func get_value_end() -> int:
	is_faild_assert()
	return string_offset + string.length() if value_end == -1 else string_offset + value_end
## 如果键在这个列，返回 [code]true[/code]。
func is_column_at_key(column : int) -> bool:
	is_faild_assert()
	return false if key_start == -1 else column > key_start + string_offset if key_end == -1 else column > key_start + string_offset and column <= string_offset + key_end
## 如果值在这个列，返回 [code]true[/code]。
func is_column_at_value(column : int) -> bool:
	is_faild_assert()
	return column > value_start + string_offset if value_end == -1 else column > value_start + string_offset and column <= value_end + string_offset

## 快速设置参数。[br]
## [param ks] -> [code]key_end[/code]，[param ve] -> [code]value_end[/code]。
func set_param_element(ks := -1, ke := -1, vs := -1, ve := -1) -> void:
	key_start = ks
	key_end = ke
	value_start = vs
	value_end = ve

