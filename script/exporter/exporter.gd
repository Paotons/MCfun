class_name Exporter
extends Resource
## 导出。
# HACK 仅针对字符串。

## 原始字符串。
var from : String
## 转化后的字符串。
var to : String
## 错误。
var errors : PackedStringArray

## 获取处理过后的字节。
func get_bytes() -> PackedByteArray:
	return to.to_utf8_buffer()
## 获取结果。
func get_result() -> String:
	return to

## 虚函数，开始导出。
@warning_ignore("unused_parameter")
func _start(text : String) -> void:
	return

## 开始处理 [param text]。
func start(text : String) -> void:
	_start(text)
