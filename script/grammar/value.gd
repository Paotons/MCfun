@tool @abstract
class_name GrammarValue
extends Object
## 静态类，语法变量。

## 变量类型。
enum Type {
	## 错误。
	ERR = -1,
	## 未知，空，占位。
	NIL = 0,
	
	#region 基础。
	## 布尔，本质上就是只有 true 和 false 的选项。
	BOOL,
	## 整数。
	INT,
	## 浮点。
	FLOAT,
	## 字符串。
	STRING,
	#endregion
	
	#region 高级。
	## 单词。
	WORD,
	## 选项。
	OPTION,
	## 空间物品。
	SPACEITEM,
	## 富文本。
	RICH_STRING,
	## 点号路径。
	POINT_PATH,
	## 文件路径。
	FILE_PATH,
	## 轴。
	COORD,
	## 范围。
	SCOPE,
	## 多个轴，可实现坐标。
	COORDS,
	## 目标选择器。
	SELECTOR,
	#endregion
	
	#region 顶级。
	## 引号包括的。
	QUOTATION,
	## 大括号包括的，类似字典。
	DICTIONARY,
	## 中括号包括的，类似数组。
	ARRAY,
	## 指令。
	COMMAND,
	#endregion
}

# 变量类型的字符串模式的映射表。
const _TYPE_STRING_MAPPING : Dictionary[Type, String] = {
	Type.NIL : "null",
	
	Type.BOOL : "bool",
	Type.INT : "int",
	Type.FLOAT : "float",
	Type.STRING : "string",
	
	Type.WORD : "word",
	Type.OPTION : "option",
	Type.SPACEITEM : "spaceitem",
	Type.RICH_STRING : "rich_string",
	Type.POINT_PATH : "point_path",
	Type.FILE_PATH : "file_path",
	Type.SCOPE : "scope",
	Type.COORD : "coord",
	Type.COORDS : "coords",
	Type.SELECTOR : "selector",
	
	Type.QUOTATION : "quotation",
	Type.DICTIONARY : "dictionary",
	Type.ARRAY : "array",
	Type.COMMAND : "command",
}

## 变量类型转化成字符串。
static func type_to_string(type : Type) -> String:
	return _TYPE_STRING_MAPPING[type] if 0 <= type and type < _TYPE_STRING_MAPPING.size() else "null"
## 字符串转化成类型，失败返回 -1。
static func string_to_type(string : String) -> Type:
	for i in _TYPE_STRING_MAPPING:
		if _TYPE_STRING_MAPPING[i] == string:
			return i
	return Type.ERR
## 如果变量类型是括号类别，则返回 [code]true[/code]。
static func is_type_backet(type : Type) -> bool:
	return type == Type.QUOTATION or type == Type.DICTIONARY or type == Type.ARRAY
## 如果变量是括号类别，返回这个括号的开头。
static func get_type_backet_start(type : Type) -> String:
	return {Type.ARRAY : "[", Type.DICTIONARY : "{", Type.QUOTATION : "\""}.get(type, "")
## 如果变量是括号类别，返回这个括号的结尾。
static func get_type_backet_end(type : Type) -> String:
	return {Type.ARRAY : "]", Type.DICTIONARY : "}", Type.QUOTATION : "\""}.get(type, "")

