@abstract class_name GrammerArrayRule
extends GrammerRule
## 数组式存放的属性。
##
## 每个属性都是数组的一个值，这是个抽象类，你不应该实例它。

## 规则。
var data_main : Array

## 获取所有参数数量。
func key_size() -> int:
	return data_main.size()
## 获取规则。
func get_element_rule(idx := 0) -> ElementRule:
	var rule := ElementRule.new()
	rule.data_main = data_main[idx]
	return rule

## 解析数组规则。
@warning_ignore("shadowed_variable")
static func _compile_array_rules(data : Array, rules_compiled : Array, _law : Dictionary, min_size := 0, max_size := -1) -> bool:
	max_size = 0xFFFFFFFF if max_size == -1 else max_size
	if not(min_size <= data.size() and data.size() <= max_size):
		push_error("Array size is %d,but it only at %d..%d." % [data.size(), min_size, max_size])
		return true
	rules_compiled.resize(data.size())
	for i in data.size():
		var property_data = data[i]
		var property_data_compiled : Dictionary
		if not property_data is Dictionary:
			push_error("Property data should be dictionary, but is %s." % [type_string(typeof(property_data))])
			return true
		var result = ElementRule.compile(property_data)
		if result == null: return true
		property_data_compiled = result
		rules_compiled[i] = property_data_compiled
	return false
