class_name GrammerParamBacketRule
extends GrammerArrayRule
## 单参数括号。

func _get_type() -> int:
	return RuleType.PARAM_BACKET
func _get_backet_type() -> int:
	return BacketElementManager.Type.PARAM
func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]

static func _compile(rule_data : Dictionary, result : Dictionary, law : Dictionary) -> bool:
	if not rule_data.has("data"):
		push_error("Not has data.")
		return true
	var rules_ = rule_data["data"]
	if not rules_ is Array:
		push_error("Properties shound be dictionary, but is %s." % [type_string(typeof(rules_))])
		return true
	var rules_compiled : Array
	if _compile_array_rules(rules_, rules_compiled, law, 1, 1):
		return true
	rule_data[RuleMeta.DATA] = rules_compiled
	result[GrammerRule.RuleMeta.DATA] = rules_compiled
	return false

