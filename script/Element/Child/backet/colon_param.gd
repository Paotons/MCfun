class_name ColonParamBacketElement
extends MultiParamBacketElement
## 冒号参数括号。

## 语法规则。
var grammer_rule : GrammarColonParamBacketRule

func _get_backet_type() -> int:
	return BacketElementManager.Type.COLON_PARAM
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return super(edit)
func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	if not has_backet_column(column): return null
	
	var param_idx := get_param_index_from_column(column)
	
	if is_params_empty() or is_param_empty(param_idx):
		data.hint_string = "<proerty : String>"
		data.insert_texts.append_array(grammer_rule.get_keys())
		data.fill_insert_mode(CodeCompletionData.InsertMode.QUOTATION)
		data.fill_inserted_update(true)
		return data
	
	var param := get_param(param_idx)
	if param == null: return data
	
	data = param.get_column_code_completion_data(column, rule, command)
	data = CodeCompletionData.new() if data == null else data
	if not is_closed() and not param.has_error():
		data.insert_texts.append(end_backet)
	return data

static func create(text : String, offset : int, start := "{", end := "}", rule : GrammarColonParamBacketRule = null) -> ColonParamBacketElement:
	var element := _create_backet_element(ColonParamBacketElement.new(), text, offset, start, end) as ColonParamBacketElement
	if element.is_faild:
		return element
	
	var length := element.get_backet_string_end()
	text = text.substr(0, length)
	var index := element.get_backet_string_start()
	while index < length:
		var sult := ColonParamElement.create(text, index, rule)
		if sult.is_faild:
			element.create_error(index, "Not find param.")
			element.params.append(null)
			var split := text.find(",", index)
			if split == -1:
				break
			element.split_flags.append(split)
			index = split + 1
		else:
			element.params.append(sult)
			for err in sult.errors: element.create_error(err.column, err.string)
			var split := text.find(",", sult.get_valid_end())
			if split == -1:
				break
			element.split_flags.append(split - offset)
			index = split + 1
	element.grammer_rule = rule
	return element


## 获取参数的键值。
func get_key_strings() -> PackedStringArray:
	if is_faild:
		push_error("The result is faild, but get something.")
		return []
	var sult : PackedStringArray
	for param in params:
		sult.append(param.get_key_string() if param != null else "")
	return sult
## 获取参数的值的字符串。
func get_value_strings() -> PackedStringArray:
	if is_faild:
		push_error("The result is faild, but get something.")
		return []
	var sult : PackedStringArray
	for param in params:
		sult.append(param.get_value_string() if param != null else "")
	return sult


