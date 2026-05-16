@abstract
class_name GrammarDictionaryRuleCompiler
extends GrammarRuleCompiler
## 语法字典式规则解析器。
##
## 抽象类，你不应该实例化。

## [b]Protected:[/b]解析字典规则，存入 [param out] 中。
func _compile_dictionary_rules(from : Dictionary, name : String, out : Dictionary) -> bool:
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, name):
		return false
	if not _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY, name):
		return false
	
	for property : String in from:
		var obj := ElementRuleCompiler.new()
		obj.element_name = "%s[%s]" % [name, property]
		
		obj.compile(from[property])
		
		_add_error_from_object(obj)
		if not obj.is_valid():
			return false
		out[property] = obj.get_result()
	return true

