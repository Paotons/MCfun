class_name GrammerEntry
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
func get_chapter(chapter : String) -> GrammerChapter:
	if not main_data.has(chapter): return null
	var res : GrammerChapter
	var data := main_data[chapter] as Dictionary
	var type := data[GrammerChapter.ChapterMeta.TYPE] as int
	match type:
		GrammerChapter.ChapterType.SPACEITEM : res = GrammerSpaceItemChapter.new()
		GrammerChapter.ChapterType.STRING : res = GrammerStringChapter.new()
		GrammerChapter.ChapterType.PATH : res = GrammerPathChapter.new()
		_: return null
	res.set_data(data)
	return res

## 编译。
func compile(data : Dictionary) -> void:
	var to : Dictionary
	for chapter_name in data:
		if not chapter_name is String:
			push_error("String name should be string, but is %s." % [type_string(typeof(chapter_name))])
			return
		var chapter = data[chapter_name]
		var to_chapter : Dictionary
		if not chapter is Dictionary:
			push_error("string should be string, but is %s." % [type_string(typeof(chapter))])
			return
		if _compiled_chapter(chapter, to_chapter): return
		to[chapter_name] = to_chapter
	main_data = to

## 解析章节。
func _compiled_chapter(from : Dictionary, to : Dictionary) -> bool:
	if _compile_chapter_type(from, to): return true
	var type := to[GrammerChapter.ChapterMeta.TYPE] as int
	match type:
		GrammerChapter.ChapterType.SPACEITEM:
			GrammerSpaceItemChapter.compile(from, to)
		GrammerChapter.ChapterType.STRING:
			GrammerStringChapter.compile(from, to)
		GrammerChapter.ChapterType.PATH:
			GrammerPathChapter.compile(from, to)
	return false

# 解析章节类型。
func _compile_chapter_type(from : Dictionary, to : Dictionary) -> bool:
	if from.has("type"):
		var string = from["type"]
		if not string is String:
			push_error("Chapter type not is string, but is %s." % [type_string(typeof(string))])
			return true
		var type := GrammerChapter.string_to_type(string)
		if type == -1:
			push_error("Unvalid type \"%s\"." % [string])
			return true
		to[GrammerChapter.ChapterMeta.TYPE] = type
		return false
	else:
		push_error("Not has type in chapter.")
		return true
