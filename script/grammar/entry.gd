class_name GrammarEntry
extends Resource
## 语法的账目。

## 分类的名称。
enum CategoryType {
	## 物品名。
	ITEM_NAME,
	## 实体名。
	ENTITY_NAME,
	## 未知。
	UNKNOW,
}

## 分类的名称字符串模式。
const _CATEGORY_STRING : Dictionary[CategoryType, String] = {
	CategoryType.ITEM_NAME : "item_name",
	CategoryType.ENTITY_NAME : "entity_name",
}

## 数据。
var main_data : Dictionary

## 设置数据。
func set_data(data : Dictionary) -> void:
	main_data = data

## 获取类对应的字符串。
static func category_to_string(category : CategoryType) -> String:
	return _CATEGORY_STRING[category] if _CATEGORY_STRING.has(category) else ""
## 获取字符串表示的类。
static func string_to_category(string : String) -> CategoryType:
	for category in _CATEGORY_STRING:
		if _CATEGORY_STRING[category] == string:
			return category
	return CategoryType.UNKNOW

## 如果为空，返回 [code]true[/code]。
func is_empty() -> bool:
	return main_data.is_empty()
## 如果有类，返回 [code]true[/code]。
func has_chapter(chapter : String) -> bool:
	return main_data.has(chapter)
## 获取章节。
func get_chapter(chapter : String) -> GrammarChapter:
	if not main_data.has(chapter): return null
	var res : GrammarChapter
	var data := main_data[chapter] as Dictionary
	var type := data[GrammarChapter.ChapterMeta.TYPE] as int
	match type:
		GrammarChapter.ChapterType.SPACEITEM : res = GrammarSpaceItemChapter.new()
		GrammarChapter.ChapterType.STRING : res = GrammarStringChapter.new()
		GrammarChapter.ChapterType.PATH : res = GrammarPathChapter.new()
		_: return null
	res.set_data(data)
	return res
