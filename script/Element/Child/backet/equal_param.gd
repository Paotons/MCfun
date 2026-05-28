class_name EqualParamBacketElement
extends MultiParamBacketElement
## 等号式参数括号。

## 语法规则。
var grammer_rule : GrammarEqualParamBacktedRule

func _get_backet_type() -> int:
	return BacketElementManager.Type.EQUAL_PARAM
## 根据编辑器返回对应的高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return super(edit)
func _get_column_code_completion_data(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
	if grammer_rule == null:
		return
	var data := FunctionCompletionData.new()
	if not has_backet_column(column):
		return null
	
	var param_idx := get_param_index_from_column(column)
	
	if is_params_empty() or is_param_empty(param_idx):
		if grammer_rule.is_using_key():
			var key_rule := grammer_rule.get_element_rule("key")
			var type := key_rule.get_type()
			var ele_type := ElementManager.value_type_to_type(type)
			data.add_data(ElementManager.get_precast_code_completion_data(ele_type, column, key_rule, command))
			return data
		else:
			data.hint_string = "<proerty : String>"
			data.insert_texts.append_array(grammer_rule.get_keys())
			data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
			data.fill_inserted_update(true)
			return data
	
	var param := get_param(param_idx)
	if param == null:
		return data
	
	data = param.get_column_code_completion_data(column, rule, command)
	data = FunctionCompletionData.new() if data == null else data
	if not is_closed() and not param.has_error():
		data.insert_texts.append(end_backet)
	return data

static func create(text : String, offset : int, start := "{", end := "}", rule : GrammarEqualParamBacktedRule = null) -> EqualParamBacketElement:
	var element := _create_backet_element(EqualParamBacketElement.new(), text, offset, start, end)
	if element.is_faild or rule == null:
		return element
	
	element.grammer_rule = rule
	
	var length := element.get_backet_string_end()
	var index := element.get_backet_string_start()
	text = text.substr(0, length)
	while index < length:
		var result := EqualParamElement.create(text, index, rule)
		if result.is_faild:
			element.create_error(index, "Not find param.")
			element.params.append(null)
		else:
			element.params.append(result)
			for err in result.errors: element.create_error(err.column, err.string)
			index = result.get_valid_end()
		var split := text.find(",", index)
		if split == -1: break
		element.split_flags.append(split - offset)
		index = split + 1
	return element

## 获取参数的键值。
func get_keys() -> PackedStringArray:
	is_faild_assert()
	var result : PackedStringArray
	for param in params:
		result.append(param.get_key())
	return result
## 获取参数的值的字符串。
func get_value_strings() -> PackedStringArray:
	is_faild_assert()
	var result : PackedStringArray
	for param in params:
		result.append(param.get_value_string())
	return result

