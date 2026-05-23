@abstract class_name Element
extends RefCounted
## 获取到底结果。
##
## 抽象类，你不应该实例化这个类。

## 是否失败。
var is_faild := true
## 错误。
var errors : Array[ElementError]

@warning_ignore("unused_parameter")
## 虚函数，获取空位补全数据。
static func get_precast_code_completion_data(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
	return null
@warning_ignore("unused_parameter")
## 虚函数，获取补全的当前数据。
func _get_column_code_completion_data(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
	return null
## 获取补全的当前数据。
func get_column_code_completion_data(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
	is_faild_assert()
	return _get_column_code_completion_data(column, rule, command)

@warning_ignore("unused_parameter")
## 虚函数，获取高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {}
## 获取高亮数据。
func get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	is_faild_assert()
	return _get_highlight(edit)

## TEST 检查一次是否失败，失败则断点。
func is_faild_assert() -> void:
	assert(is_faild == false, "Element is faild.")

## 创建一个错误。
func create_error(column : int, string : String, type := ElementError.Type.NOTFIND) -> void:
	var err := ElementError.new()
	err.column = column
	err.string = string
	err.type = type
	errors.append(err)
## 如果有错误，返回 [code]true[/code]。
func has_error() -> bool:
	return not errors.is_empty()

## 移除在指定范围之外的错误。
func remove_error_from_range(from : int, to : int) -> void:
	var new_errs : Array[ElementError] = errors.filter(_is_error_at_range.bind(from, to))
	errors = new_errs

# 如果错误是否在指定范围，返回 true。
func _is_error_at_range(err : ElementError, from : int, to : int) -> bool:
	return from <= err.column and err.column < to

