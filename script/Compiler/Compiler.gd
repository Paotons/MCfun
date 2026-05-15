@abstract
class_name Compiler
extends Resource
## 解析器。
##
## 用于将各种变量的转化。抽象类，你不应该实例化。

var _is_valid := false

## 解析的结果。
var compiled_result : Variant
## 错误。
var errors : PackedStringArray

## 虚函数，解析。
@warning_ignore("unused_parameter")
func _compile(data : Variant) -> void:
	return

## 解析函数。
func compile(data : Variant) -> void:
	_compile(data)
## 获取原始数据。
func get_data() -> Dictionary:
	return {}
## 获取结果。
func get_result() -> Variant:
	return compiled_result
## 如果数据可用，返回 [code]true[/code]。
func is_valid() -> bool:
	return _is_valid

## [b]Protected:[/b]用于设置 [method is_vaild] 返回值。
func _set_is_valid(enabled := true) -> void:
	_is_valid = enabled
## [b]Protected:[/b]用于解析时，判断变量是否为指定类型，如果成功，返回 [code]true[/code]，如果失败，会记一次错误，并返回 [code]false[/code]。
func _test_value_type(value : Variant, types : int, value_name := "Value") -> bool:
	if types >> typeof(value) & 1 != 0:
		return true
	else:
		errors.append("%s should be %s, but is %s." % [value_name, _type_strings(types), type_string(typeof(value))])
		return false
## [b]Protescted:[/b]用于解析时，判断字典值的类型是否为指定类型，如果成功，返回 [code]true[/code]，如果失败，会记下错误，并返回 [code]false[/code]。。
func _test_dictionary_value_types(dict : Dictionary, types : int, dict_name := "Dict") -> bool:
	var ok := true
	for key in dict:
		if types >> typeof(dict[key]) & 1 == 0:
			errors.append("%s[%s] should be %s, but is %s." % [dict_name, key, _type_strings(types), type_string(typeof(dict[key]))])
			ok = false
	return ok
## [b]Protescted:[/b]用于解析时，判断字典键的类型是否为指定类型，如果成功，返回 [code]true[/code]，如果失败，会记下错误，并返回 [code]false[/code]。
func _test_dictionary_key_types(dict : Dictionary, types : int, dict_name := "Dict") -> bool:
	var ok := true
	for key in dict:
		if types >> typeof(key) & 1 == 0:
			errors.append("%s keys should be %s, but %s is %s." % [dict_name, _type_strings(types), key, type_string(typeof(key))])
			ok = false
	return ok
## [b]Protescted:[/b]用于解析时，判断变量类型是否为指定类型的数组，指定长度，如果成功，返回 [code]true[/code]，如果失败，会记下错误，并返回 [code]false[/code]。
func _test_array_types(arr : Array, types : int, arr_name := "Arr", size := -1) -> bool:
	var ok := true
	for i in arr.size():
		if types >> typeof(arr[i]) & 1 == 0:
			errors.append("%s[%s] should be %s, but is %s." % [arr_name, i, _type_strings(types), type_string(typeof(arr[i]))])
			ok = false
	if size >= 0 and arr.size() != size:
		errors.append("%s size should be %d, but is %d." % [arr_name, size, arr.size()])
	return ok
## [b]Protescted:[/b]用于解析时，判断数组类型是否为指定类型，指定长度，如果成功，返回 [code]true[/code]，如果失败，会记下错误，并返回 [code]false[/code]。
func _test_value_array_types(value : Variant, types : int, value_name := "Value", size := -1) -> bool:
	return _test_value_type(value, 1 << TYPE_ARRAY, value_name) and _test_array_types(value, types, value_name, size)

## [b]Protected:[/b]用于解析。[br]
## 如果 [param dict] 有 [param key]，[br]
## 通过 [param run][code](value)(int)[/code] 判断是否可用，[br]
## 然后通过 [param transform] 将值转化，[br]
## 存入 [member compild_result] 的 [param to_key]，并返回 [code]true[/code]。[br]
## 如果 [param force] 为 [code]false[/code] 时，屏蔽没有键报的错。其他情况下都会存入错误，并返回 [code]false[/code]。
func _try_dictionary_key(
	dict : Dictionary,
	dict_name : String,
	key : Variant,
	to_key : Variant = key,
	force := true,
	run := Callable(),
	transform := Callable(),
) -> bool:
	
	if not dict.has(key):
		if force:
			errors.append("%s not has %s." % [dict_name, key])
			return false
		else:
			return true
	
	if not run.is_null() and not run.call(dict[key]):
		return false
	
	compiled_result[to_key] = transform.call(dict[key]) if not transform.is_null() else dict[key]
	return true
## [b]Protected:[/b]用于解析。见 [method _try_dictionary_key]。只是直接采用的值。
func _try_dictionary_key_direct(dict : Dictionary, dict_name : String, key : Variant, to_key : Variant = key, force := true) -> bool:
	if not dict.has(key):
		if force:
			errors.append("%s not has %s." % [dict_name, key])
			return false
		else:
			return true
	
	compiled_result[to_key] = dict[key]
	return true

## [b]Protected:[/b]添加错误信息，把错误信息从 [param obj] 添加到本地来。
func _add_error_from_object(obj : Compiler) -> void:
	errors.append_array(obj.errors)

# 将多个类型转化为字符串。
func _type_strings(types : int) -> String:
	var result : PackedStringArray
	var index := 0
	while types != 0:
		if types & 1 == 1:
			result.append(type_string(index))
		index += 1
		types >>= 1
	return "|".join(result)

