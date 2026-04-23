class_name ElementError
extends RefCounted
## 获取结果的错误。

enum Type {
	## 指定起始位置不准确。
	UNvalid_START,
	## 不可用字符串。
	UNVALID_STRING,
	
	## 没有找到匹配项目。
	NOTFIND,
}

## 位置。
var column := -1
## 错误类型。
var type : Type
## 错误字符串。
var string : String

