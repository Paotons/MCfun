class_name GrammerEqualParamBacktedRule
extends GrammerDictionaryRule
## 等号式括号规则。
##
## 描述 [GetedEqualParamResult] 和 [GetedEqualParamBacketResult] 的。

# 默认细节。
enum _DetailMeta {
	USING_KEY = 0, # 使用键
}
const _DEFAULT_DETAIL := [false]

var detail_main : Array

func _get_backet_type() -> int:
	return BacketElementManager.Type.EQUAL_PARAM

func _get_type() -> int:
	return GrammerRule.RuleType.EQUAL_PARAM_BACKET

func _set_data(data : Dictionary) -> void:
	data_main = data[RuleMeta.DATA]
	detail_main = data[RuleMeta.DETAIL]

## 如果使用键，返回 [code]true[/code]。
func is_using_key() -> bool:
	return detail_main[_DetailMeta.USING_KEY]

#region 解析。
static func _compile(from : Dictionary, to : Dictionary, law : Dictionary) -> bool:
	if _compile_detail(from, to): return true
	if _compile_data(from, to, law): return true
	return false

static func _compile_data(from : Dictionary, to : Dictionary, law : Dictionary) -> bool:
	if not from.has("data"):
		push_error("Not has data.")
		return true
	var data = from["data"]
	if not data is Dictionary:
		push_error("Properties shound be dictionary, but is %s." % [type_string(typeof(data))])
		return true
	var to_data : Dictionary
	if _compile_dictionary_rules(data, to_data, law):
		return true
	to[GrammerRule.RuleMeta.DATA] = to_data
	return false

static func _compile_detail(from : Dictionary, to : Dictionary) -> bool:
	if not from.has("detail"):
		to[RuleMeta.DETAIL] = _DEFAULT_DETAIL
		return false
	
	var detail = from["detail"]
	if not detail is String:
		push_error("Properties shound be string, but is %s." % [type_string(typeof(detail))])
		return true
	
	var to_detail := _DEFAULT_DETAIL.duplicate()
	for slice in (detail as String).split(","):
		if slice == "using_key":
			to_detail[_DetailMeta.USING_KEY] = true
	
	to[GrammerRule.RuleMeta.DETAIL] = to_detail
	return false

#endregion
