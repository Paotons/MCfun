class_name GrammarEntry
extends Resource
## 语法的账目。

## 分类的名称。
enum ChapterType {
	## 目标选择器的头。
	SELECTOR_HEAD,
	## 物品名。
	ITEM_NAME,
	## 实体名。
	ENTITY_NAME,
	## 未知。
	UNKNOW,
}

## 分类的名称字符串模式。
const _CHAPTER_STRING : Dictionary[ChapterType, String] = {
	ChapterType.SELECTOR_HEAD : "selector_head",
	ChapterType.ITEM_NAME : "item_name",
	ChapterType.ENTITY_NAME : "entity_name",
}

## 数据。
var main_data : Dictionary

#region 缓存。
# 目标选择器头部补全数据。
var _selector_head_completion_data : FunctionCompletionData
#region

## 设置数据。
func set_data(data : Dictionary) -> void:
	main_data = data

## 返回目标选择头部补全。
func get_selector_head_completion_data() -> FunctionCompletionData:
	if _selector_head_completion_data != null:
		return _selector_head_completion_data
	var name := chapter_to_string(ChapterType.SELECTOR_HEAD)
	
	if not has_chapter(name):
		_selector_head_completion_data = FunctionCompletionData.new()
		return _selector_head_completion_data
	var chapter := get_chapter(name)
	
	if chapter is GrammarStringChapter:
		var data := FunctionCompletionData.new()
		data.insert_texts.append_array(chapter.get_items())
		data.display_texts.append_array(chapter.get_displays())
		data.fill_insert_mode(FunctionCompletionData.InsertMode.SELECTOR)
		data.fill_inserted_update(true)
		data.supple()
		_selector_head_completion_data = data
		return data
	else:
		_selector_head_completion_data = FunctionCompletionData.new()
		return _selector_head_completion_data
## 返回类对应的字符串。
static func chapter_to_string(chapter : ChapterType) -> String:
	return _CHAPTER_STRING[chapter] if _CHAPTER_STRING.has(chapter) else ""
## 返回字符串表示的类。
static func string_to_chapter(string : String) -> ChapterType:
	for chapter in _CHAPTER_STRING:
		if _CHAPTER_STRING[chapter] == string:
			return chapter
	return ChapterType.UNKNOW

## 如果为空，返回 [code]true[/code]。
func is_empty() -> bool:
	return main_data.is_empty()
## 如果有类，返回 [code]true[/code]。
func has_chapter(chapter : String) -> bool:
	return main_data.has(chapter)
## 返回指定章节。
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
