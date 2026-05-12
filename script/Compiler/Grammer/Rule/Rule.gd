@abstract
class_name GrammerRuleCompiler
extends GrammerCompiler
## 语法规则解析器。
##
## 抽象类，你不应该实例化。

## 元素类型。
enum RuleMeta {
	## 类型。
	TYPE,
	## 类型的细节。
	DETAIL,
	## 数据。
	DATA,
}

## 整个法令。
var law : Dictionary
## 规则名称。
var rule_name : String

