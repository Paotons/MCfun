class_name NativeCommandElementParserValues
extends Resource
## 解析本地指令的变量。

## 变量。
var values : Dictionary
## 默认值。
var value_default : Variant

## 返回值。
func get_value(name : String) -> Variant:
	return values.get(name, value_default)
## 设置值。
func set_value(name : String, value : Variant) -> void:
	values[name] = value
