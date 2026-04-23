@abstract class_name GrammerDictionaryRule
extends GrammerRule
## 字典式存放的属性。
##
## 每个属性都对应一个字符串键。这是个抽象类，你不应该实例它。

## 规则。
var data_main : Dictionary

## 获取所有参数。
func get_keys() -> PackedStringArray:
	return data_main.keys()

## 如果有这个键，返回 [code]true[/code]。
func has_key(key : String) -> bool:
	return data_main.has(key)

## 获取结果。
func get_element_rule(key : String) -> ElementRule:
	if not data_main.has(key): return null
	var rule := ElementRule.new()
	rule.data_main = data_main[key]
	return rule

## 解析字典规则。
static func _compile_dictionary_rules(data : Dictionary, rules_compiled : Dictionary, _law : Dictionary) -> bool:
	for property in data:
		if not property is String:
			push_error("Property should be string, but is %s." % [type_string(typeof(property))])
			return true
		var property_data = data[property]
		var property_data_compiled : Dictionary
		if not property_data is Dictionary:
			push_error("Property data should be dictionary, but is %s." % [type_string(typeof(property_data))])
			return true
		var element = ElementRule.compile(property_data)
		if element == null: return true
		property_data_compiled = element
		rules_compiled[property] = property_data_compiled
	return false
