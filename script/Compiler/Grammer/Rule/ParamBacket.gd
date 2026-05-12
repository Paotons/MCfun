class_name GrammerParamBacketRuleCompiler
extends GrammerArrayRuleCompiler
## 参数括号的解析器。

func _compile(data : Variant) -> void:
	var from := data as Dictionary
	if not from.has("data"):
		errors.append("%s not has data." % rule_name)
		return
	if not _test_value_type(from["data"], 1 << TYPE_ARRAY, "%s[data]" % rule_name):
		return
	
	var out : Array
	if not _compile_array_rules(from["data"], "%s[data]" % rule_name, out, 1, 1):
		return
	compiled_result[RuleMeta.DATA] = out
	is_faild = false

