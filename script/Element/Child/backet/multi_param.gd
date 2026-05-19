@abstract
class_name MultiParamBacketElement
extends BacketElement
## 多参数括号。
##
## 抽象类，你不能实例化这个类。

## 参数。
var params : Array[Element]
## 参数分割符位置。
var split_flags : PackedInt32Array

func _get_backet_type() -> int:
	return -1
## 根据编辑器返回对应的高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	for param in params:
		if param == null or param.is_faild:
			continue
		result.merge(param.get_highlight(edit), true)
	return result
func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	if not has_backet_column(column): return null
	
	var param_idx := get_param_index_from_column(column)
	if param_idx == -1:
		breakpoint
		return null
	
	var param := get_param(param_idx)
	if param == null: return data
	
	data = param.get_column_code_completion_data(column, rule, command)
	data = FunctionCompletionData.new() if data == null else data
	if not is_closed() and not param.has_error():
		data.insert_texts.append(end_backet)
	return data

## 获取列在参数键中的序列。
func get_param_index_from_column(column : int) -> int:
	is_faild_assert()
	if not has_backet_column(column):
		return -1
	
	var column_local := column - string_offset
	for i in range(split_flags.size() - 1, -1, -1):
		var split_flag := split_flags[i]
		if column_local > split_flag:
			return i + 1
	return 0

## 如果这个参数是空参数，返回 [code]true[/code]。
func is_param_empty(idx : int) -> bool:
	is_faild_assert()
	if 0 <= idx and idx < params.size():
		return params[idx] == null
	else:
		return idx == params.size() and is_end_with_empty_param() # 以空参数收尾而且还是最后一个参数
## 如果是以空参数结尾，返回 [code]true[/code]。
func is_end_with_empty_param() -> bool:
	is_faild_assert()
	var txt : String
	if split_flags.is_empty():
		txt = get_backeted_string()
	else:
		var last_split := split_flags[split_flags.size() - 1]
		txt = string.substr(last_split + 1, get_backet_string_end() - string_offset - last_split - 1)
	return txt == " ".repeat(txt.length())

## 如果为空，返回 [code]true[/code]。
func is_params_empty() -> bool:
	return is_faild or params.is_empty()

## 获取参数数量。
func get_param_count() -> int:
	is_faild_assert()
	return params.size()
## 获取参数。
func get_param(idx : int) -> Element:
	is_faild_assert()
	return params[idx] if idx >= 0 and idx < params.size() else null
