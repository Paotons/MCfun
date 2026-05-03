class_name GrammerArrayBacketRule
extends GrammerArrayRule
## 数组括号。

func _get_backet_type() -> int:
	return BacketElementManager.Type.ARRAY

func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]

static func _compile(rule_data : Dictionary, result : Dictionary, law : Dictionary) -> bool:
	if not rule_data.has("data"):
		push_error("Array not has data.")
	else:
		var rule_ = rule_data["data"]
		if rule_ is Array:
			var rule_compiled : Array
			if _compile_array_rules(rule_, rule_compiled, law):
				return true
			result[RuleMeta.DATA] = rule_compiled
		else:
			push_error("Array detail should be string, but is %s." % [type_string(typeof(rule_))])
			return true
	return false

