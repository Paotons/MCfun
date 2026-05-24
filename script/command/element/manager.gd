@abstract
class_name CommandElementManager
extends Object
## 指令元素的管理。
##
## 静态类，你不应该实例化。

## 指令类型。
enum CommandType {
	## 空指令。
	EMPTY = 1 << 0,
	## 普通指令。
	NORMAL = 1 << 1,
	## 最开始，根部。
	ROOT = 1 << 2,
	## 直接替代原来的父指令，直达最后，类型于 execute run 分支一样。
	REPLACE = 1 << 3,
	## 以问号开头的指令。
	HELP = 1 << 4,
	## 注释。
	ANNOTATION = 1 << 5,
	## 本地指令。
	NATIVE = 1 << 6,
	## 注解。
	COMMENT = 1 << 7,
}

# 指令类型映射表。
const _COMMAND_TYPE_STRING_MAP : Dictionary[int, String] = {
	CommandType.EMPTY : "empty",
	CommandType.NORMAL : "normal",
	CommandType.ROOT : "root",
	CommandType.REPLACE : "replace",
	CommandType.HELP : "help",
	CommandType.ANNOTATION : "annotation",
	CommandType.NATIVE : "native",
	CommandType.COMMENT : "comment"
}

## 返回指令的类型的字符串。
static func command_type_to_string(types : int) -> String:
	var result : PackedStringArray
	for key in _COMMAND_TYPE_STRING_MAP:
		if types & key != 0:
			result.append(_COMMAND_TYPE_STRING_MAP[key])
	return "|".join(result)
## 返回某个字符串对应的指令类型。
static func string_to_command_type(string : String) -> int:
	var res := 0
	for value in string.split("|", false):
		for key in _COMMAND_TYPE_STRING_MAP:
			if _COMMAND_TYPE_STRING_MAP[key] == value:
				res |= key
	return res

