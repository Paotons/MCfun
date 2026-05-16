class_name GrammarParamBacketRule
extends GrammarArrayRule
## 单参数括号。

func _get_type() -> int:
	return RuleType.PARAM_BACKET
func _get_backet_type() -> int:
	return BacketElementManager.Type.PARAM
func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]


