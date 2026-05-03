@abstract class_name GrammerRule
extends RefCounted
## 语法规则。
##
## 所有语法规则的基类，你不应该实例它。

## 规则类型。
enum RuleType {
	## 单参数括号。
	PARAM_BACKET,
	## 等号参数括号。
	EQUAL_PARAM_BACKET,
	## 字典括号。
	COLON_PARAM_BACKET,
	## 数组括号。
	ARRAY_BACKET,
}
## 元素类型。
enum RuleMeta {
	## 类型。
	TYPE,
	## 类型的细节。
	DETAIL,
	## 数据。
	DATA,
}

# 规则类型转化为字符串映射表。
const _TYPE_TO_STRING_MAP : Dictionary[RuleType, String] = {
	RuleType.PARAM_BACKET : "param_backet",
	RuleType.EQUAL_PARAM_BACKET : "equal_param_backet",
	RuleType.COLON_PARAM_BACKET : "colon_param_backet",
	RuleType.ARRAY_BACKET : "array_backet",
}

# 元素转化为字符串的映射表。
const _META_TO_STRING_MAP : Dictionary[RuleMeta, String] = {
	RuleMeta.TYPE : "type",
	RuleMeta.DETAIL : "detail",
	RuleMeta.DATA : "data",
}

@warning_ignore("unused_parameter")
## 设置数据，虚函数。
func _set_data(data : Dictionary) -> void:
	return
## 设置数据。
func set_data(data : Dictionary) -> void:
	_set_data(data)

## 返回括号类别，虚函数。
func _get_backet_type() -> int:
	return -1
## 如果是规定括号规则的，返回 [code]true[/code]。
func is_backet_rule() -> bool:
	return _get_backet_type() != -1
## 获取括号类别。
func get_backet_type() -> int:
	return _get_backet_type()

## 获取类型。
func _get_type() -> int:
	return -1

@warning_ignore("unused_parameter")
## 解析等号参数括号规则，用于 [GrammerLaw]，失败返回 [code]true[/code]。
static func _compile(rule_data : Dictionary, result : Dictionary, law : Dictionary) -> bool:
	push_error("Cannt compile in null rule.")
	return true

## 获取类型。
func get_type() -> int:
	return _get_type()

## 通过字符串获取规则类型。
static func string_to_type(string : String) -> int:
	for type in _TYPE_TO_STRING_MAP:
		if _TYPE_TO_STRING_MAP[type] == string:
			return type
	return -1
## 通过规则类型获取字符串。
static func type_to_string(type : int) -> String:
	return _TYPE_TO_STRING_MAP[type] if _TYPE_TO_STRING_MAP.has(type) else ""



