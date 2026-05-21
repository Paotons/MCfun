class_name GrammarStringChapterCompiler
extends GrammarChapterCompiler
## 章目字符串解析器。

class _Item extends GrammarCompiler:
	enum _MetaType {
		# 物品。
		ITEMS,
		# 物品的显示。
		DISPLAYS,
	}
	
	var chapter : String
	
	func _compile(data : Variant) -> void:
		compiled_result = {}
		if data is Array:
			_compile_v1(data)
		elif data is Dictionary:
			_compile_v2(data)
		else:
			errors.append("%s[data] is %s, but should be array/dictionary." % [chapter, type_string(typeof(data))])
	
	# 版本1，数组里都是字符串。
	func _compile_v1(from : Array) -> void:
		if not _test_array_types(from, 1 << TYPE_STRING, "%s[data]" % chapter):
			return
		compiled_result[_MetaType.ITEMS] = from
		compiled_result[_MetaType.DISPLAYS] = []
		_set_is_valid(true)
	
	# 版本2，字典里两两字符。
	func _compile_v2(from : Dictionary) -> void:
		if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "%s[data]" % chapter):
			return
		if not _test_dictionary_value_types(from, 1 << TYPE_STRING, "%s[data]" % chapter):
			return
		var keys := from.keys()
		var values : Array # 出于顺序安全，不敢用 values()
		values.resize(keys.size())
		for i in keys.size():
			values[i] = from[keys[i]]
		compiled_result[_MetaType.ITEMS] = keys
		compiled_result[_MetaType.DISPLAYS] = values
		_set_is_valid(true)

# 解析数据。
func _compile(data : Variant) -> void:
	var from := data as Dictionary
	
	compiled_result = {}
	if not from.has("data"):
		errors.append("%s not has data." % [chapter_name])
		return
	if not _test_value_type(from["data"], 1 << TYPE_ARRAY | 1 << TYPE_DICTIONARY, "%s[data]" % chapter_name):
		return
	
	var obj := _Item.new()
	obj.chapter = chapter_name
	obj.compile(from["data"])
	if not obj.is_valid():
		return
	
	compiled_result[ChapterMeta.DATA] = obj.get_result()
	_set_is_valid(true)


