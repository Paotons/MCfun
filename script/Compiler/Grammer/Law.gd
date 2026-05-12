class_name GrammerLawCompiler
extends GrammerCompiler
## 语法规则解析器。

func _compile(data : Variant) -> void:
	var from := data as Dictionary
	compiled_result = {}
	
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "Law"):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY, "Law"):
		return
	
	for rule_name : String in from:
		if not _compile_rule(from[rule_name], rule_name, from):
			return
	is_faild = false

# 解析规则。
func _compile_rule(from : Dictionary, name : String, law : Dictionary) -> bool:
	if not _compile_type(from, name):
		return false
	var to := compiled_result[name] as Dictionary
	var type := to[GrammerRule.RuleMeta.TYPE] as int
	
	var obj : GrammerRuleCompiler
	match type:
		GrammerRule.RuleType.PARAM_BACKET: 
			obj = GrammerParamBacketRuleCompiler.new()
		GrammerRule.RuleType.EQUAL_PARAM_BACKET:
			obj = GrammerEqualParamBacketRuleCompiler.new()
		GrammerRule.RuleType.COLON_PARAM_BACKET:
			obj = GrammerColonParamBacketRuleCompiler.new()
		GrammerRule.RuleType.ARRAY_BACKET:
			obj = GrammerArrayBacketRuleCompiler.new()
	
	obj.compiled_result = to
	obj.law = law
	obj.rule_name = name
	obj.compile(from)
	
	_add_error_from_object(obj)
	if not obj.is_valid():
		return false
	to.merge(obj.get_result())
	return true

func _compile_type(from : Dictionary, name : String) -> bool:
	if from.has("type"):
		if not _test_value_type(from["type"], 1 << TYPE_STRING, "Law[%s]" % name):
			return false
		var string := from["type"] as String
		var type := GrammerRule.string_to_type(string)
		if type == -1:
			errors.append("Law[%s][type] is %s, but can not used." % [name, string])
			return false
		compiled_result[name] = {}
		compiled_result[name][GrammerRuleCompiler.RuleMeta.TYPE] = type
		return true
	else:
		errors.append("Law[%s] not has type." % name)
		return false

