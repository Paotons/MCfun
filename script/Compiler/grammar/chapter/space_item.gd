class_name GrammarSpaceItemChapterCompiler
extends GrammarChapterCompiler
## 物品空间章目解析器。

class _Space extends GrammarCompiler:
	var chapter : String
	
	func _compile(data : Variant) -> void:
		var from : Dictionary = data
		
		compiled_result = {}
		if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "%s[data]" % chapter):
			return
		
		if not _test_dictionary_value_types(from, 1 << TYPE_ARRAY | 1 << TYPE_DICTIONARY, "%s[data]" % chapter):
			return
		
		for space : String in from:
			var obj := _Item.new()
			obj.chapter = chapter
			obj.space = space
			obj.compile(from[space])
			if not obj.is_valid():
				return
			
			compiled_result[space]= obj.get_result()
		_set_is_valid(true)

class _Item extends GrammarCompiler:
	var chapter : String
	var space : String
	
	# 空间下的物品的物品。
	const _ITEM_ITEMS := 0
# 空间下的物品的显示。
	const _ITEM_DIZPLAYS := 1
	
	func _compile(data : Variant) -> void:
		compiled_result = {}
		if data is Array:
			_compile_v1(data)
		elif data is Dictionary:
			_compile_v2(data)
	
	func _compile_v1(from : Array) -> void:
		if not _test_array_types(from, 1 << TYPE_STRING, "%s[data][%s]" % [chapter, space]):
			return
		compiled_result[_ITEM_ITEMS] = from
		compiled_result[_ITEM_DIZPLAYS] = []
		_set_is_valid(true)
	
	func _compile_v2(from : Dictionary) -> void:
		if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "%s[data][%s]" % [chapter, space]):
			return
		if not _test_dictionary_value_types(from, 1 << TYPE_STRING, "%s[data][%s]" % [chapter, space]):
			return
		var keys := from.keys()
		var values : Array
		values.resize(keys.size())
		for i in keys.size():
			values[i] = from[keys[i]]
		compiled_result[_ITEM_ITEMS] = keys
		compiled_result[_ITEM_DIZPLAYS] = values
		_set_is_valid(true)

## 解析数据。
func _compile(data : Variant) -> void:
	var from : Dictionary = data
	
	compiled_result = {}
	if not from.has("data"):
		errors.append("%s not has data." % [chapter_name])
		return
	
	if not _test_value_type(from["data"], 1 << TYPE_DICTIONARY, "%s[data]" % chapter_name):
		return
	
	var obj := _Space.new()
	obj.chapter = chapter_name
	obj.compile(from["data"])
	if not obj.is_valid():
		return
	
	compiled_result[ChapterMeta.DATA] = obj.get_result()
	_set_is_valid(true)
	return




