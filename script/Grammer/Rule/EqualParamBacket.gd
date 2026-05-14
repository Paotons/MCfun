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
