class_name GrammarLaw
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
func get_selector_body_rule() -> GrammarEqualParamBacktedRule:
	return get_rule(SELECTOR_BODY_RULE_NAME)

## 获取规则。
func get_rule(name : String) -> GrammarRule:
	if main_data.has(name):
		var rule_data : Dictionary = main_data[name]
		var type : int = rule_data[GrammarRule.RuleMeta.TYPE]
		var rule : GrammarRule
		match type:
			GrammarRule.RuleType.PARAM_BACKET:
				rule = GrammarParamBacketRule.new()
			GrammarRule.RuleType.EQUAL_PARAM_BACKET:
				rule = GrammarEqualParamBacktedRule.new()
			GrammarRule.RuleType.COLON_PARAM_BACKET:
				rule = GrammarColonParamBacketRule.new()
			GrammarRule.RuleType.ARRAY_BACKET:
				rule = GrammarArrayBacketRule.new()
			_:
				breakpoint # 正常情况，不可能到这里来
		rule.set_data(rule_data)
		return rule
	return null
