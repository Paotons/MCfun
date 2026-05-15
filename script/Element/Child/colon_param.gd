class_name ColonParamElement
extends DoubleParamElement
## 冒号参数。
##
## 类似于 [code]key : value[/code] 模式，目前仅支持字符串的键。

## 语法规则。
var grammer_rule : GrammerColonParamBacketRule
## 冒号位置。
var colon_flag := -1

static var _colon_param_regex := RegEx.create_from_string(
	r"^ *(?<key>%s)(?: *(?<colon>:)(?: *(?<value>%s))?)?" % [r"\"([^\"]|(?<=\\)\")+(?:(?<!\\)\")?|[^,: \t]+", r"\"([^\"]|(?<=\\)\")+(?:(?<!\\)\")?|[^, \t]+"]
)
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	if has_key():
		result.merge({get_key_start() : {"color" : edit.color_member}, get_key_end() : {"color" : edit.color_default}})
	if has_value():
		if value_element != null:
			if value_element is StringElement:
				result.merge(value_element.get_highlight(edit), false)
	return result
func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	
	# 键
	if is_column_at_key(column):
		data.insert_texts.append_array(grammer_rule.get_keys())
		data.fill_insert_mode(CodeCompletionData.InsertMode.QUOTATION)
		data.hint_string = "<proerty : String>"
		
		var key := get_key_string()
		if grammer_rule.has_key(key):
			data.supple()
			data.insert_texts.append(":")
			data.set_inserted_update(-1, true)
		return data
	
	# 值
	elif is_column_at_value(column):
		if not grammer_rule.has_key(get_key_string()):
			return null
		if value_element != null and value_element is StringElement and not value_element.is_faild:
			return (value_element as StringElement).get_column_code_completion_data(column, rule, command)
		
		data.hint_string = "<%s : %s>" % [get_key_string(), GrammerValue.type_to_string(value_type)]
		if not has_value() and GrammerValue.is_type_backet(value_type):
			data.supple()
			data.add_data(CodeCompletionData.create_backet_data(value_type))
	return data

static func create(text : String, offset : int, rule : GrammerColonParamBacketRule = null) -> ColonParamElement:
	var element := ColonParamElement.new()
	element.string_offset = offset
	element.grammer_rule = rule
	
	var result := _colon_param_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find any string.")
		return element
	
	# 键
	element.valid_start = result.get_start("key")
	element.key_start = result.get_start("key")
	var key := result.get_string("key")
	var is_key_has_quotation_ := key.begins_with("\"")
	element.key_element = BacketElement.create(text, element.key_start + offset, "\"", "\"") if is_key_has_quotation_ else null
	element.key_end = element.key_element.get_valid_end() - offset if is_key_has_quotation_ else result.get_end("key")
	
	if is_key_has_quotation_ and not element.key_element.is_closed():
		element.create_error(element.key_start, "Key not has closed backet.")
		element.string = text.substr(offset, element.key_end)
		element.is_faild = false
		return element
	
	var rereule := rule.get_element_rule(key)
	element.value_type = rereule.get_type() if rule != null and rule.has_key(key) else -1
	if element.value_type == -1:
		element.create_error(element.value_start, "Rule not find property \"%s\"." % [key])
		element.string = text.substr(offset, element.key_end)
		element.is_faild = false
		return element
	
	# 冒号
	element.colon_flag = result.get_start("colon")
	if element.colon_flag == -1:
		element.create_error(element.key_end, "Not find colon flag.")
		element.string = text.substr(offset, element.key_end)
		element.is_faild = false
		return element
	
	# 值
	element.value_start = result.get_start("value")
	if element.value_start == -1:
		element.create_error(element.colon_flag, "Not find value")
		element.string = text.substr(offset, element.colon_flag + 1)
		element.is_faild = false
		return element
	
	var text_ := text if GrammerValue.is_type_backet(rereule.get_type()) else text.substr(0, text.find(",", element.colon_flag + offset))
	var value = ElementManager.create_from_rule(text_, offset + element.value_start, rereule)
	for err in value.errors:
		element.create_error(element.value_start + offset, "Value has error \"%s\"." % [err.string])
	
	element.value_element = value
	if value == null or value.is_faild:
		element.create_error(element.colon_flag + offset, "Not find value.")
		element.string = text.substr(offset, element.colon_flag)
		element.value_start = -1
		element.is_faild = false
		return element
	if value is StringElement:
		element.string = text.substr(offset, value.get_valid_end() - offset)
	element.is_faild = false
	return element

## 如果序列在键的位置，返回 [code]true[/code]。
func is_column_at_key(column : int) -> bool:
	is_faild_assert()
	return get_key_start() <= column and column <= get_key_end()
## 如果这个列处于值，则返回 [code]true[/code]。
func is_column_at_value(column : int) -> bool:
	is_faild_assert()
	return get_value_start() < column and column <= get_value_end() if has_value() else get_colon() < column

## 获取冒号位置。
func get_colon() -> int:
	is_faild_assert()
	return -1 if colon_flag == -1 else colon_flag + string_offset
## 如果有冒号，返回 [code]true[/code]。
func has_colon() -> bool:
	is_faild_assert()
	return colon_flag != -1
## 如果键带有引号，返回 [code]true[/code]。
func is_key_has_quotation() -> bool:
	is_faild_assert()
	return key_element != null and key_element is BacketElement and key_element.start_backet == "\""

