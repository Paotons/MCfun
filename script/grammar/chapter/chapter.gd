@abstract
class_name GrammarChapter
extends Resource
## 语法章节。
##
## 提供一些补全基础的。

## 章节类型。
enum ChapterType {
	## 普通字符串。
	STRING,
	## 空间物品。
	SPACEITEM,
	## 路径。
	PATH,
}

## 章节元素。
enum ChapterMeta {
	## 类型。
	TYPE,
	## 细节。
	DETAIL,
	## 数据。
	DATA,
}

# 章节类型转化成字符串映射表。
const _CHAPTER_TYPE_TO_STRING_MAP : Dictionary[ChapterType, String] = {
	ChapterType.STRING : "string",
	ChapterType.SPACEITEM : "spaceitem",
	ChapterType.PATH : "path",
}

@warning_ignore("unused_parameter")
## 虚函数，设置数据。
func _set_data(data : Dictionary) -> void:
	return
## 设置数据。
func set_data(data : Dictionary) -> void:
	_set_data(data)

## 虚函数，获取类型。
@abstract func _get_type() -> ChapterType;
## 获取类型。
func get_type() -> ChapterType:
	return _get_type()

## 字符串转化为类型。
static func string_to_type(string : String) -> int:
	for type in _CHAPTER_TYPE_TO_STRING_MAP:
		if _CHAPTER_TYPE_TO_STRING_MAP[type] == string:
			return type
	return -1

