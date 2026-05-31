class_name GrammarColonParamBacketRuleCompiler
extends GrammarDictionaryRuleCompiler
## 语法冒号参数括号解析器。

func _compile(data : Variant) -> void:
	var from := data as Dictionary
	if not from.has("data"):
		errors.append("%s not has data." % rule_name)
		return
	if not _test_value_type(from["data"], 1 << TYPE_DICTIONARY, "%s[data]" % rule_name):
		return
	
	var out : Dictionary
	if not _compile_dictionary_rules(data["data"], "%s[data]" % rule_name, out, cmd_list_types):
		return
	compiled_result[GrammarRule.RuleMeta.DATA] = out
	_set_is_valid(true)
