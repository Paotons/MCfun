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


