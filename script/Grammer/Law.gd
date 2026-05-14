class_name GrammerLaw
extends RefCounted
## 语法规则。

## 对于目标选择匹配身体部分使用的数据。
const SELECTOR_BODY_RULE_NAME := "selector_body"

# 解析过的数据。
var main_data : Dictionary

## 设置数据。
func set_data(data : Dictionary) -> void:
	main_data = data

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
