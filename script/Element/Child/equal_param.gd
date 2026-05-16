class_name EqualParamElement
extends DoubleParamElement
## 等号参数元素。
##
## 这个类一般都是搭配 [GetedEqualParamBacketResult] 使用的。[br]
## 格式类似 [code]type=array [/code], 或者是 [code] type=!array [/code]。[br]

## 语法规则。
var grammer_rule : GrammarEqualParamBacktedRule

## 等号位置。
var equal_flag := -1
## 非号位置。
var not_flag := -1

static var _equal_param_searched_regex := RegEx.create_from_string(r"^(?<start> *)(?<key>[^ \t=]+)(?: *(?<equal>=))?(?: *(?<not>!))?(?: *(?<value_begin>.))?")
static func create(text : String, offset : int, rule : GrammarEqualParamBacktedRule = null) -> EqualParamElement:
	if rule.is_using_key():
		return _create_using_key(text, offset, rule)
	var element := EqualParamElement.new()
	element.string_offset = offset
	element.grammer_rule = rule
	
	var result := _equal_param_searched_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find any string.")
		return element
	element.valid_start = result.get_end("start")
	
	element.key_start = result.get_start("key")
	element.key_end = result.get_end("key")
	
	# 键
	var key := result.get_string("key")
	var rerule := rule.get_element_rule(key)
	element.value_type = rerule.get_type() if rule != null and rule.has_key(key) else -1
	if element.value_type == -1:
		element.create_error(result.get_start("key"), "Not find key \"%s\" in rule." % [key])
		element.string = text.substr(offset, element.key_end)
		element.is_faild = false
		return element
	
	# 等号
	element.equal_flag = result.get_start("equal")
	if element.equal_flag == -1:
		element.create_error(offset + element.key_end, "Not has equal.")
		element.string = text.substr(offset, element.key_end)
		element.is_faild = false
		return element
	
	# 非修饰
	element.not_flag = result.get_start("not")
	
	# 值
	element.value_start = result.get_start("value_begin")
	if element.value_start == -1:
		element.create_error(offset + maxi(element.equal_flag, element.not_flag), "Not has value.")
		element.string = text.substr(offset, maxi(element.not_flag, element.equal_flag) + 1)
		element.is_faild = false
		return element
	var text_ := text if GrammarValue.is_type_backet(element.value_type) else text.substr(0, text.find(",", maxi(element.equal_flag, element.not_flag) + offset))
	var value := ElementManager.create_from_rule(text_, offset + element.value_start, rerule)
	
	element.value_element = value
	if value == null or value.is_faild:
		element.create_error(maxi(element.not_flag, element.equal_flag) + offset, "Not find value.")
		element.string = text.substr(offset, maxi(element.equal_flag, element.not_flag))
		element.value_start = -1
		element.is_faild = false
		return element
	if value is StringElement:
		element.string = text.substr(offset, value.get_valid_end() - offset)
	element.is_faild = false
	return element
static func _create_using_key(text : String, offset : int, rule : GrammarEqualParamBacktedRule) -> EqualParamElement:
	var element := EqualParamElement.new()
	element.string_offset = offset
	element.grammer_rule = rule
	
	# 键
	var key_ele_rule := rule.get_element_rule("key")
	element.key_type = key_ele_rule.get_type()
	var text_ := text if GrammarValue.is_type_backet(element.key_type) else text.substr(0, text.find("=", offset))
	var key_ele : StringElement = ElementManager.create_from_rule(text_, offset, key_ele_rule)
	element.key_element = key_ele
	
	if key_ele == null or key_ele.is_faild:
		element.create_error(offset, "Not find key.")
		return element
	element.key_start = key_ele.get_valid_start() - offset
	element.key_end = key_ele.get_valid_end() - offset
	for err in key_ele.errors: element.create_error(err.column, err.string)
	
	# 符号
	var i := key_ele.get_valid_end()
	i = StrT.find_unempty(text, i)
	if i == -1 or text[i] != "=":
		element.create_error(key_ele.get_valid_end(), "Not find equal.")
		element.string = text.substr(offset, key_ele.get_valid_end() - offset)
		element.is_faild = false
		return element
	element.equal_flag = i - offset
	
	@warning_ignore("unused_variable")
	var is_not := false
	i = StrT.find_unempty(text, i + 1)
	if i == -1:
		element.create_error(i, "Not find value.")
		element.string = text.substr(offset, key_ele.get_valid_end() - offset)
		element.is_faild = false
		return element
	elif text[i] == "!":
		element.not_flag = i - offset
		is_not = true
	
	# 值。
	var value_ele_rule := rule.get_element_rule("value")
	element.value_type = value_ele_rule.get_type()
	text_ = text
	var value_ele : StringElement = ElementManager.create_from_rule(text_, i, value_ele_rule)
	element.value_element = value_ele
	
	if value_ele == null or value_ele.is_faild:
		element.create_error(i, "Not find value.")
		element.string = text.substr(offset, key_ele.get_valid_end() - offset)
		element.is_faild = false
		return element
	element.value_start = value_ele.get_valid_start() - offset
	element.value_end = value_ele.get_valid_end() - offset
	for err in element.errors: element.create_error(err.column, err.string)
	
	element.is_faild = false
	return element

func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	if grammer_rule.is_using_key():
		return _get_column_code_completion_data_using_key(column, rule, command)
	var data := CodeCompletionData.new()
	
	# 键
	if is_column_at_key(column):
		data.insert_texts.append_array(grammer_rule.get_keys())
		data.fill_insert_mode(CodeCompletionData.InsertMode.WORLD)
		data.fill_inserted_update(true)
		data.hint_string = "<proerty : String>"
		
		var key := get_key_string()
		if grammer_rule.has_key(key):
			data.insert_texts.append("=")
			data.set_inserted_update(-1, true)
		return data
	
	# 值
	elif is_column_at_value(column):
		var key := get_key_string()
		if not grammer_rule.has_key(key):
			return null
		if value_element == null:
			var result_rule := grammer_rule.get_element_rule(key)
			var type := ElementManager.value_type_to_type(value_type)
			data.supple()
			data.add_data(ElementManager.get_precast_code_completion_data(type, column, result_rule, command))
		elif value_element is StringElement and not value_element.is_faild:
			var result_rule := grammer_rule.get_element_rule(key)
			return (value_element as StringElement).get_column_code_completion_data(column, result_rule, command)
		data.hint_string = "<%s : %s>" % [get_key_string(), GrammarValue.type_to_string(value_type)]
		match value_type:
			GrammarValue.Type.DICTIONARY, GrammarValue.Type.ARRAY, GrammarValue.Type.QUOTATION:
				data.supple() ; data.add_data(CodeCompletionData.create_backet_data(value_type))
	return data
func _get_column_code_completion_data_using_key(column : int, _rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	if is_column_at_key(column):
		var key_rule := grammer_rule.get_element_rule("key")
		if key_element != null and not key_element.is_faild:
			data.insert_texts.append("=")
			data.supple()
			data.add_data(key_element.get_column_code_completion_data(column, key_rule, command))
	
	# 值
	elif is_column_at_value(column):
		var value_rule := grammer_rule.get_element_rule("value")
		if value_element != null and not value_element.is_faild:
			data.insert_texts.append("=")
			data.supple()
			data.add_data(value_element.get_column_code_completion_data(column, value_rule, command))
	return data

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	if grammer_rule.is_using_key():
		if key_element != null and not key_element.is_faild:
			result.merge(key_element.get_highlight(edit), true)
		if value_element != null and not value_element.is_faild:
			result.merge(value_element.get_highlight(edit), true)
	else:
		if has_key():
			result.merge({get_key_start() : {"color" : edit.color_member}, get_key_end() : {"color" : edit.color_default}})
		if has_value():
			if value_element != null:
				if value_element is StringElement:
					result.merge(value_element.get_highlight(edit))
	return result

func is_column_at_key(column : int) -> bool:
	is_faild_assert()
	return super(column) or (column - string_offset <= equal_flag if has_equal() else true)
func is_column_at_value(column : int) -> bool:
	is_faild_assert()
	return super(column) or column - string_offset >= maxi(equal_flag, not_flag)

## 获取等号位置。
func get_equal() -> int:
	if is_faild:
		push_error("The result is faild, but get something.")
		return -1
	return string_offset + equal_flag if equal_flag != -1 else -1
## 获取非号位置。
func get_not() -> int:
	if is_faild:
		push_error("The result is faild, but get something.")
		return -1
	return string_offset + not_flag if not_flag != -1 else -1

## 如果有非，返回 [code]true[/code]。
func has_not() -> bool:
	if is_faild:
		push_error("The result is faild, but get something.")
		return false
	return not_flag != -1
## 如果有等号，返回 [code]true[/code]。
func has_equal() -> bool:
	if is_faild:
		push_error("The result is faild, but get something.")
		return false
	return equal_flag != -1
