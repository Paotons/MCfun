class_name GrammerStringChapterCompiler
extends GrammerChapterCompiler
## 章目字符串解析器。

class _Item extends GrammerCompiler:
	var chapter : String
	
	func _compile(data : Variant) -> void:
		var from := data as Array
		
		if _test_array_types(from, 1 << TYPE_STRING, "%s[data]" % chapter):
			return
		compiled_result = from
		_set_is_valid(true)

# 解析数据。
func _compile(data : Variant) -> void:
	var from := data as Dictionary
	
	compiled_result = {}
	if not from.has("data"):
		errors.append("%s not has data." % [chapter_name])
		return
	if not _test_value_type(from["data"], 1 << TYPE_ARRAY, "%s[data]" % chapter_name):
		return
	
	var obj := _Item.new()
	obj.chapter = chapter_name
	obj.compile(from["data"])
	if not obj.is_valid():
		return
	
	compiled_result[ChapterMeta.DATA] = obj.get_result()
	_set_is_valid(true)


