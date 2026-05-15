class_name GrammerArrayBacketRule
extends GrammerArrayRule
## 数组括号。

func _get_backet_type() -> int:
	return BacketElementManager.Type.ARRAY

func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]


