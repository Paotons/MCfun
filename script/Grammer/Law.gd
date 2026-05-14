class_name GrammerLaw
extends RefCounted
## 语法规则。

## 对于目标选择匹配身体部分使用的数据。
const SELECTOR_BODY_RULE_NAME := "selector_body"

# 解析过的数据。
var main_data : Dictionary

## 有规则。
func has_rule(name : String) -> bool:
	return main_data.has(name)
## 获取目标选择器身体部分使用的规则。
func get_selector_body_rule() -> GrammerEqualParamBacktedRule:
	return get_rule(SELECTOR_BODY_RULE_NAME)

## 获取规则。
func get_rule(name : String) -> GrammerRule:
	if main_data.has(name):
		var rule_data : Dictionary = main_data[name]
		var type : int = rule_data[GrammerRule.RuleMeta.TYPE]
		var rule : GrammerRule
		match type:
			GrammerRule.RuleType.PARAM_BACKET:
				rule = GrammerParamBacketRule.new()
			GrammerRule.RuleType.EQUAL_PARAM_BACKET:
				rule = GrammerEqualParamBacktedRule.new()
			GrammerRule.RuleType.COLON_PARAM_BACKET:
				rule = GrammerColonParamBacketRule.new()
			GrammerRule.RuleType.ARRAY_BACKET:
				rule = GrammerArrayBacketRule.new()
		if rule == null:
			push_error("Not find rule.")
			return null
		rule.set_data(rule_data)
		return rule
	return null

## 解析。
func compile(data : Dictionary) -> void:
	var result : Dictionary
	for rule_name in data:
		if not rule_name is String:
			push_error("Rule name not is string, but is %s." % [type_string(typeof(rule_name))])
			return
		var rule = data[rule_name]
		var compiled_rule : Dictionary
		if not rule is Dictionary:
			push_error("Rule not is dictionary, but is %s." % [type_string(typeof(rule))])
			return
		_compile_rule(rule, compiled_rule, data)
		result[rule_name] = compiled_rule
	print_rich("[color=#069]", result)
	main_data = result

# 解析规则。
static func _compile_rule(rule : Dictionary, compiled_rule : Dictionary, law : Dictionary) -> void:
	if _compile_rule_type(rule, compiled_rule): return
	var type : int = compiled_rule[GrammerRule.RuleMeta.TYPE]
	match type:
		GrammerRule.RuleType.PARAM_BACKET: 
			GrammerParamBacketRule._compile(rule, compiled_rule, law)
		GrammerRule.RuleType.EQUAL_PARAM_BACKET:
			GrammerEqualParamBacktedRule._compile(rule, compiled_rule, law)
		GrammerRule.RuleType.COLON_PARAM_BACKET:
			GrammerColonParamBacketRule._compile(rule, compiled_rule, law)
		GrammerRule.RuleType.ARRAY_BACKET:
			GrammerArrayBacketRule._compile(rule, compiled_rule, law)

# 解析规则的类型。
static func _compile_rule_type(from : Dictionary, to : Dictionary) -> bool:
	if from.has("type"):
		var string = from["type"]
		if not string is String:
			push_error("Rule type not is string, but is %s." % [type_string(typeof(string))])
			return true
		var type := GrammerRule.string_to_type(string)
		if type == -1:
			push_error("Unvalid type \"%s\"." % [string])
			return true
		to[GrammerRule.RuleMeta.TYPE] = type
		return false
	else:
		push_error("Not has type in rule.")
		return true
