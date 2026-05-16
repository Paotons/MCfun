class_name ParamBacketElement
extends BacketElement
## 一个括号包括的独立参数。

## 参数结果。
var value_element : StringElement
## 规则。
var grammer_rule : GrammarParamBacketRule
## 变量类型。
var value_type := -1

func _get_backet_type() -> int:
	return BacketElementManager.Type.PARAM

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	if value_element != null:
		if value_element is StringElement:
			result.merge(value_element.get_highlight(edit), true)
	else:
		super(edit)
	return result
func _get_column_code_completion_data(column : int, _rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	var result_rule := grammer_rule.get_element_rule()
	if value_element == null:
		var result_type := ElementManager.value_type_to_type(value_type)
		return ElementManager.get_precast_code_completion_data(result_type, column, result_rule, command)
	elif value_element is StringElement:
		return value_element.get_column_code_completion_data(column, result_rule, command)
	return data

static func create(text : String, offset : int, start := "\"", end := "\"", rule : GrammarParamBacketRule = null) -> ParamBacketElement:
	var element := BacketElement._create_backet_element(ParamBacketElement.new(), text, offset, start, end) as ParamBacketElement
	element.grammer_rule = rule
	if element.is_faild:
		return element
	
	var element_rule := rule.get_element_rule()
	element.value_type = element_rule.get_type()
	element.value_element = ElementManager.create_from_rule(text.substr(0, element.get_backet_string_end()), element.get_backet_string_start(), element_rule)
	
	if element.value_element == null or element.value_element.is_faild:
		element.value_element = null
		element.create_error(element.get_backet_string_start(), "Not find value.")
		return element
	return element


