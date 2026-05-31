class_name GrammarLawCompiler
extends GrammarCompiler
## 语法规则解析器。

enum LawMeta {
	# HACK 并无用处。
	## 描述。
	DESCRIPTION,
	## 数据。
	DATA,
	## 元列表类型。
	CMD_LIST_TYPES,
}

func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("Law_data should be dictionary, but is %s." % type_string(typeof(data)))
		return
	
	var from : Dictionary = data
	compiled_result = {}
	compiled_result[LawMeta.DATA] = {}
	compiled_result[LawMeta.CMD_LIST_TYPES] = PackedStringArray()
	
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "Law"):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY, "Law"):
		return
	
	for rule_name : String in from:
		if not _compile_rule(from[rule_name], rule_name, from):
			return
	_set_is_valid(true)

# 解析规则。
func _compile_rule(from : Dictionary, name : String, law : Dictionary) -> bool:
	if not _compile_type(from, name):
		return false
	var to := compiled_result[name] as Dictionary
	var type := to[GrammarRule.RuleMeta.TYPE] as int
	
	var obj : GrammarRuleCompiler
	match type:
		GrammarRule.RuleType.PARAM_BACKET: 
			obj = GrammarParamBacketRuleCompiler.new()
		GrammarRule.RuleType.EQUAL_PARAM_BACKET:
			obj = GrammarEqualParamBacketRuleCompiler.new()
		GrammarRule.RuleType.COLON_PARAM_BACKET:
			obj = GrammarColonParamBacketRuleCompiler.new()
		GrammarRule.RuleType.ARRAY_BACKET:
			obj = GrammarArrayBacketRuleCompiler.new()
	
	obj.compiled_result = to
	obj.law = law
	obj.rule_name = name
	obj.compile(from)
	
	_add_error_from_object(obj)
	if not obj.is_valid():
		return false
	to.merge(obj.get_result())
	_append_cmd_list_types(obj.cmd_list_types)
	return true

func _compile_type(from : Dictionary, name : String) -> bool:
	if from.has("type"):
		if not _test_value_type(from["type"], 1 << TYPE_STRING, "Law[%s]" % name):
			return false
		var string := from["type"] as String
		var type := GrammarRule.string_to_type(string)
		if type == -1:
			errors.append("Law[%s][type] is %s, but can not used." % [name, string])
			return false
		compiled_result[name] = {}
		compiled_result[name][GrammarRuleCompiler.RuleMeta.TYPE] = type
		return true
	else:
		errors.append("Law[%s] not has type." % name)
		return false

# 加入指令列表。
func _append_cmd_list_types(types : PackedStringArray) -> void:
	var cmd_list_types : PackedStringArray = compiled_result[LawMeta.CMD_LIST_TYPES]
	cmd_list_types.append_array(types)
