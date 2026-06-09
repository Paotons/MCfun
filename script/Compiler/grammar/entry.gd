class_name GrammarEntryCompiler
extends GrammarCompiler
## 解析账目的类。
##
## 能够将字典转化成 [GrammarEntry] 可用的数据。

var entry_name := "Entry"

## 获取结果。
func get_result() -> Dictionary:
	return compiled_result

## 编译。
func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("%s should be dictionary, but is %s." % [entry_name, type_string(typeof(data))])
		return
	
	var from : Dictionary = data
	compiled_result = {}
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, entry_name):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY, entry_name):
		return
	
	for chapter_name : String in data:
		if not _compiled_chapter(from[chapter_name], chapter_name, "%s[%s]" % [entry_name, chapter_name]):
			return
	_set_is_valid(true)

# 解析章节。
func _compiled_chapter(from : Dictionary, key : String, name : String) -> bool:
	var to : Dictionary
	if not _compile_chapter_type(from, to, name):
		return false
	
	var type := to[GrammarChapter.ChapterMeta.TYPE] as int
	
	var obj : GrammarChapterCompiler
	match type:
		GrammarChapter.ChapterType.SPACEITEM:
			obj = GrammarSpaceItemChapterCompiler.new()
		GrammarChapter.ChapterType.STRING:
			obj = GrammarStringChapterCompiler.new()
		GrammarChapter.ChapterType.PATH:
			obj = GrammarPathChapterCompiler.new()
	obj.compiler_data = compiler_data
	obj.chapter_name = name
	obj.compile(from)
	
	if not obj.is_valid():
		errors = obj.errors
		return false
	
	to.merge(obj.get_result())
	compiled_result[key] = to
	return true

# 解析章节类型，成功返回 [code]true[/code]，失败报错并返回 [code]false[/code]。
func _compile_chapter_type(from : Dictionary, to : Dictionary, name : String) -> bool:
	if not from.has("type"):
		errors.append("%s not has type." % [name])
		return false
	
	if not _test_value_type(from["type"], 1 << TYPE_STRING, name):
		return false
	
	var type_str := from["type"] as String
	var type := GrammarChapter.string_to_type(type_str)
	if type == -1:
		errors.append("%s[type] is %s, can not used." % [name, type_str])
		return false
	
	to[GrammarChapter.ChapterMeta.TYPE] = type
	return true


