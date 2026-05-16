@abstract class_name GrammarDictionaryRule
extends GrammarRule
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
