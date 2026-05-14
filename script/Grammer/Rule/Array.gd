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
