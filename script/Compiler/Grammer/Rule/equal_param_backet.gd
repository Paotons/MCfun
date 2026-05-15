class_name GrammerEqualParamBacketRuleCompiler
extends GrammerDictionaryRuleCompiler
## 等号参数括号解析器。

enum _DetailMeta {
	USING_KEY = 0, # 使用键
}
const _DEFAULT_DETAIL := [false]

func _compile(data : Variant) -> void:
	if not _compile_data(data):
		return
	if not _compile_detail(data):
		return
	_set_is_valid(true)

func _compile_data(from : Dictionary) -> bool:
	if not from.has("data"):
		errors.append("%s not has data." % rule_name)
		return false
	if not _test_value_type(from["data"], 1 << TYPE_DICTIONARY, "%s[data]" % rule_name):
		return false
	
	var data := from["data"] as Dictionary
	var out : Dictionary
	if not _compile_dictionary_rules(data, "%s[data]" % rule_name, out):
		return false
	compiled_result[RuleMeta.DATA] = out
	return true

func _compile_detail(from : Dictionary) -> bool:
	if not from.has("detail"):
		compiled_result[RuleMeta.DETAIL] = _DEFAULT_DETAIL
		return true
	
	if not _test_value_type(from["detail"], 1 << TYPE_STRING, "%s[detail]" % rule_name):
		return false
	
	var detail := from["detail"] as String
	
	var to := _DEFAULT_DETAIL.duplicate()
	for slice in detail.split(","):
		if slice == "using_key":
			to[_DetailMeta.USING_KEY] = true
	
	compiled_result[RuleMeta.DETAIL] = to
	return true

