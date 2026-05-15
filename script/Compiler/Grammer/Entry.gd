class_name GrammerEntryCompiler
extends GrammerCompiler
## 解析账目的类。
##
## 能够将字典转化成 [GrammerEntry] 可用的数据。

## 获取结果。
func get_result() -> Dictionary:
	return compiled_result

## 编译。
func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("Entry_data should be dictionary, but is %s." % type_string(typeof(data)))
		return
	
	var from : Dictionary = data
	compiled_result = {}
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "Entry"):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY, "Entry"):
		return
	
	for chapter_name : String in data:
		_compiled_chapter(from[chapter_name], chapter_name)
	_set_is_valid(true)

## 解析章节。
func _compiled_chapter(from : Dictionary, name : String) -> void:
	var to : Dictionary
	if not _compile_chapter_type(from, to, name):
		return
	
	var type := to[GrammerChapter.ChapterMeta.TYPE] as int
	
	var obj : GrammerCompiler
	match type:
		GrammerChapter.ChapterType.SPACEITEM:
			obj = GrammerSpaceItemChapterCompiler.new()
		GrammerChapter.ChapterType.STRING:
			obj = GrammerStringChapterCompiler.new()
		GrammerChapter.ChapterType.PATH:
			obj = GrammerPathChapterCompiler.new()
	obj.compile(from)
	
	if not obj.is_valid():
		return
	
	to.merge(obj.get_result())
	compiled_result[name] = to

# 解析章节类型，成功返回 [code]true[/code]，失败报错并返回 [code]false[/code]。
func _compile_chapter_type(from : Dictionary, to : Dictionary, name : String) -> bool:
	if not from.has("type"):
		errors.append("%s not has type." % [name])
		return false
	
	if not _test_value_type(from["type"], 1 << TYPE_STRING, name):
		return false
	
	var type_str := from["type"] as String
	var type := GrammerChapter.string_to_type(type_str)
	if type == -1:
		errors.append("%s[\"type\"] is %s, can not used." % [name, type_str])
		return false
	
	to[GrammerChapter.ChapterMeta.TYPE] = type
	return true


