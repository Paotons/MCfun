class_name GrammarLaw
extends RefCounted
## 语法规则。

## 对于目标选择匹配身体部分使用的数据。
const SELECTOR_BODY_RULE_NAME := "selector_body"

enum LawMeta {
	# HACK 并无用处。
	## 描述。
	DESCRIPTION,
	## 数据。
	DATA,
	## 元列表类型。
	CMD_LIST_TYPES,
}

# 解析过的数据。
var main_data : Dictionary
# 指令列表类型。
var _cmd_list_types : PackedStringArray

## 设置数据。
func set_data(data : Dictionary) -> void:
	main_data = data[LawMeta.DATA]
	_cmd_list_types = data[LawMeta.CMD_LIST_TYPES]
## 返回数据。
func get_data() -> Dictionary:
	return {
		LawMeta.DATA : main_data,
		LawMeta.CMD_LIST_TYPES : _cmd_list_types,
	}

## 如果有指定名称的规则，返回 [code]true[/cde]。
func has_rule(name : String) -> bool:
	return main_data.has(name)
## 返回目标选择器身体部分使用的规则。
func get_selector_body_rule() -> GrammarEqualParamBacktedRule:
	return get_rule(SELECTOR_BODY_RULE_NAME)

## 返回规则。
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
## 返回指令列表类型。
func get_cmd_list_types() -> PackedStringArray:
	return _cmd_list_types

