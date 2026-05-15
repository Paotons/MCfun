class_name GrammerPathChapterCompiler
extends GrammerChapterCompiler
## 路径解析器。

class _Path extends GrammerCompiler:
	enum _PathMeta {
		# 表示可直接结尾。
		IS_END,
		# 表示直接结尾的成员。
		MUMBER,
		# 表示成员的分组。
		GROUP_MUMBER,
		# 分组数据。
		GROUP_DATA,
	}
	
	var chapter : String
	var path : Array[String]
	
	func _get_name() -> String:
		return "%s[data]" % chapter + "[%s]".repeat(path.size()) % path
	
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if _test_dictionary_key_types(from, 1 << TYPE_STRING, _get_name()):
			return
		if _test_dictionary_value_types(from, 1 << TYPE_DICTIONARY | 1 << TYPE_BOOL, _get_name()):
			return
		
		if from.has(""):
			compiled_result[_PathMeta.IS_END] = true
			from.erase("")
		else:
			compiled_result[_PathMeta.IS_END] = false
		
		var mumber : PackedStringArray
		var group_mumber : PackedStringArray
		var group_data : Array[Dictionary]
		for key : String in from:
			var value = from[key]
			
			if value is bool:
				mumber.append(key)
			
			elif value is Dictionary:
				group_mumber.append(key)
				var obj := _Path.new()
				obj.chapter = chapter
				obj.path = path.duplicate()
				obj.path.append(key)
				obj.compile(value)
				
				if not obj.is_valid():
					return
				group_data.append(obj.get_result())
		
		compiled_result[_PathMeta.MUMBER] = mumber
		compiled_result[_PathMeta.GROUP_MUMBER] = group_mumber
		compiled_result[_PathMeta.GROUP_DATA] = group_data
		_set_is_valid(true)

# 解析数据。
func _compile(data : Variant) -> void:
	var from := data as Dictionary
	
	if not from.has("data"):
		errors.append("%s not has data." % chapter_name)
		return
	if not _test_value_type(from["data"], 1 << TYPE_DICTIONARY, "%s[data]" % chapter_name):
		return
	
	var obj := _Path.new()
	obj.chapter = chapter_name
	obj.compile(from["data"])
	
	if not obj.is_valid():
		return
	compiled_result[ChapterMeta.DATA] = obj.get_result()
	_set_is_valid(true)



