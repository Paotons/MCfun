class_name ArrayBacketElement
extends MultiParamBacketElement
## 数组括号。

## 语法规则。
var grammer_rule : GrammarArrayBacketRule
## 参数类型。
var param_type := GrammarValue.Type.ERR

## 根据编辑器返回对应的高亮数据。
func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return super(edit)
func _get_column_code_completion_data(column : int, _rule : ElementRule, command : CommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	var result_rule := grammer_rule.get_element_rule()
	if not has_backet_column(column): return null
	
	var param_idx := get_param_index_from_column(column)
	assert(param_idx != -1, "Unvalid index.")
	
	if is_params_empty() or is_param_empty(param_idx):
		if GrammarValue.is_type_backet(param_type):
			data = FunctionCompletionData.create_backet_data(param_type)
	
	var param := get_param(param_idx)
	if param == null: return data 
	
	data = param.get_column_code_completion_data(column, result_rule, command)
	data = FunctionCompletionData.new() if data == null else data
	if not is_closed() and not param.has_error():
		data.insert_texts.append(end_backet)
	return data

static func create(text : String, offset : int, start := "[", end := "]", rule : GrammarArrayBacketRule = null) -> ArrayBacketElement:
	var element := BacketElement._create_backet_element(ArrayBacketElement.new(), text, offset, start, end) as ArrayBacketElement
	if element.is_faild:
		return element
	
	var length := element.get_backet_string_end()
	text = text.substr(0, length)
	var index := element.get_backet_string_start()
	
	var result_rule := rule.get_element_rule()
	element.param_type = result_rule.get_type()
	var is_backet := GrammarValue.is_type_backet(element.param_type)
	while index < length:
		var text_ : String = text if is_backet else text.substr(0, text.find(",", index))
		var sult := ElementManager.create_from_rule(text_, index, result_rule) as StringElement
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

