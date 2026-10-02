class_name GrammarTranslationCompiler
extends BaseGrammarCompiler
## 语法翻译解析器。

class TranslationCompiler extends BaseGrammarCompiler:
	var translation_name : String
	
	func _compile(data : Variant) -> void:
		compiled_result = {}
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
