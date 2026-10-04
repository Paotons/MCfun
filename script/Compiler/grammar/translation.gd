class_name GrammarTranslationCompiler
extends BaseGrammarCompiler
## 语法翻译解析器。

class TranslationCompiler extends BaseGrammarCompiler:
	var translation_name : String
	
	func _compile(data : Variant) -> void:
		var from := data as Dictionary
		compiled_result = {}
		
		if _is_po_file(from):
			_compile_po(from)
		else:
			_compile_json(from)
	
	func _compile_json(data : Dictionary) -> void:
		if not _test_dictionary_key_types(data, 1 << TYPE_STRING | 1 << TYPE_DICTIONARY, translation_name):
			return
		if not _test_dictionary_value_types(data, 1 << TYPE_STRING, translation_name):
			return
		
		for key in data:
			var msgage : String
			if key is String:
				msgage = key
			elif key is Dictionary:
				if not key.has("untr"):
					errors.append("%s[*] should has key \"untr\"." % translation_name)
					continue
				if not _test_value_type(key["untr"], 1 << TYPE_STRING, "%s[*][untr]" % translation_name):
					continue
				if key.has("context") and not _test_value_type(key["context"], 1 << TYPE_STRING, "%s[*][context]" % translation_name):
					continue
				
				msgage = key["untr"] + "\u0004" + key.get("context", "")
			compiled_result[msgage] = data[key]
		
		_set_is_valid(true)
	
	func _compile_po(data : Dictionary) -> void:
		var path := data["file"] as String
		var translation : Translation = load(compiler_data.path_join(path))
		if translation == null:
			errors.append("%s is unvalid po_file.")
			return
		compiled_result = _get_translation_data(translation)
		_set_is_valid(true)
	
	func _is_po_file(data : Dictionary) -> bool:
		return data.has("type") and data["type"] is String and data["type"] == "po_file" and \
			data.has("file") and data["file"] is String and (data["file"] as String).get_extension() == "po" and \
			FileAccess.file_exists(compiler_data.path_join(data["file"]))
	
	# 返回翻译器数据。
	static func _get_translation_data(translation : Translation) -> Dictionary:
		var result : Dictionary
		for key in translation.get_message_list():
			var p := key.find("\u0004")
			var untranslated : String
			var context : String
			if p == -1:
				untranslated = key
			else:
				context = key.substr(0, p)
				untranslated = key.substr(p + 1)
			result[key] = translation.get_message(untranslated, context)
		return result

func _compile(data : Variant) -> void:
	if not _test_value_type(data, 1 << TYPE_DICTIONARY, "Translation"):
		return
	
	compiled_result = {}
	if not _test_dictionary_key_types(data, 1 << TYPE_STRING, "Translation"):
		return
	if not _test_dictionary_value_types(data, 1 << TYPE_DICTIONARY, "Translation"):
		return
	
	for local : String in data:
		var obj := TranslationCompiler.new()
		obj.compiler_sync(self)
		obj.compile(data[local])
		
		errors.append_array(obj.errors)
		if not obj.is_valid():
			continue
		compiled_result[local] = obj.get_result()
	_set_is_valid(true)
