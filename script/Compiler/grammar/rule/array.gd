@abstract
class_name GrammarArrayRuleCompiler
extends GrammarRuleCompiler
## 语法数组式规则解析器。
##
## 抽象类，你不应该实例化。

func _compile_array_rules(data : Array, name : String, out : Array, min_size := 0, max_size := -1) -> bool:
	max_size = 0xFFFFFFFF if max_size == -1 else max_size
	
	if not (min_size <= data.size() and data.size() <= max_size):
		errors.append("%s size should between %d and %d, but is %d." % [name, min_size, max_size, data.size()])
		return false
	 
	if not _test_array_types(data, 1 << TYPE_DICTIONARY, name):
		return false
	
	out.resize(data.size())
	for i in data.size():
		var obj := ElementRuleCompiler.new()
		obj.element_name = "%s[%d]" % [name, i]
		obj.compile(data[i])
		
		_add_error_from_object(obj)
		if not obj.is_valid():
			return false
		out[i] = obj.get_result()
	return true
