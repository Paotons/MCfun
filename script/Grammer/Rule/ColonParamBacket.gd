class_name GrammerColonParamBacketRule
extends GrammerDictionaryRule
## 冒号式括号。
##
## 描述 [GetedColonParamResult] 和 [GetedColonParamBacketResult] 的。

func _get_type() -> int:
	return RuleType.COLON_PARAM_BACKET

func _get_backet_type() -> int:
	return BacketElementManager.Type.COLON_PARAM

func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]

static func _compile(data : Dictionary, result : Dictionary, law : Dictionary) -> bool:
	if not data.has("data"):
		push_error("Not has data.")
		return true
	var rules_ = data["data"]
	if not rules_ is Dictionary:
		push_error("Properties shound be dictionary, but is %s." % [type_string(typeof(rules_))])
		return true
	var rules_compiled : Dictionary
	if _compile_dictionary_rules(rules_, rules_compiled, law):
		return true
	result[GrammerRule.RuleMeta.DATA] = rules_compiled
	return false

