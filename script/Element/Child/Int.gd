class_name IntElement
extends DoubleParamElement
## 整数。
##
## 键是值，值是后缀。

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_number}, get_valid_end() : {"color" : edit.color_default}}

static func create(text : String, offset : int, rule : ElementRule = null) -> IntElement:
	var element := IntElement.new()
	element.string_offset = offset
	
	var result := StringElement.create(text, offset)
	if result.is_faild:
		element.create_error(offset, "Not find string.")
		return element
	element.valid_start = result.valid_start
	element.string = result.string
	
	var valiad_str := result.get_valid_string()
	var suffix := ""
	if rule != null and rule.has_detail():
		var suffix_flag := false
		for suf in rule.get_suffixs():
			if valiad_str.ends_with(suf):
				suffix = suf
				suffix_flag = true
				break
		if not suffix_flag:
			element.create_error(offset, "Not find int suffix %s in %s." % [valiad_str, rule.get_suffixs()])
			return element
	
	element.value_start = element.string.length() - suffix.length() if not suffix.is_empty() else -1
	element.value_end = element.string.length() if not suffix.is_empty() else -1
	
	var int_str := valiad_str.substr(0, valiad_str.length() - suffix.length())
	if int_str.is_valid_int():
		element.key_start = element.valid_start
		element.key_end = element.value_start
		
		var value := int_str.to_int()
		if rule != null and not (rule.get_int_min() <= value and value <= rule.get_int_max()):
			element.create_error(element.key_start + offset, "Range is %d~%d, but is %d." % [rule.get_int_min(), rule.get_int_max(), value])
		
		element.is_faild = false
		return element
	else:
		element.create_error(offset, "String \"%s\" not is valid int." % [valiad_str])
		return element

static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : int>" % [rule.get_description()]
	return data
func get_column_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : int>" % [rule.get_description()]
	if rule.has_detail():
		var suffixs := rule.get_suffixs()
		if suffixs.has(""):
			suffixs.erase("")
		data.insert_texts.append_array(suffixs)
	return data

## 如果有后缀，返回 [code]true[/code]。
func has_suffix() -> bool:
	return has_value()
## 获取后缀。
func get_suffix() -> String:
	return get_value_string()

## 获取值。
func get_value() -> int:
	is_faild_assert()
	return get_key_string().to_int()
