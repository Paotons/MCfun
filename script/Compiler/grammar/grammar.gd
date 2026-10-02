class_name GrammarCompiler
extends BaseGrammarCompiler
## 语法的解析器。
##
## 输入文件路径，解析语法数据。

## 结果类型。
enum ResultType {
	## 主文件。
	MAIN = 0,
	## 进程。
	PROCESS = 1,
	## 规则。
	LAW = 2,
	## 章类。
	ENTRY = 3,
	## 翻译。
	TRANSLATION = 4,
}

## 将解析数据设置到语法。
func set_to_grammar(grammar : Grammar) -> void:
	if not is_valid():
		push_error("Unvalid compiler.")
		return
	grammar.main = GrammarMain.new()
	grammar.main_process = GrammarProcess.new()
	grammar.law = GrammarLaw.new()
	grammar.entry = GrammarEntry.new()
	grammar.translation = GrammarTranslation.new()
	
	grammar.main.set_data(compiled_result[ResultType.MAIN])
	grammar.main_process.set_data(compiled_result[ResultType.PROCESS])
	grammar.law.set_data(compiled_result[ResultType.LAW])
	grammar.entry.set_data(compiled_result[ResultType.ENTRY])
	grammar.translation.set_data(compiled_result[ResultType.TRANSLATION])

func _compile(data : Variant) -> void:
	if not data is String:
		errors.append("data should be string(path), but is %s." % type_string(typeof(data)))
		return
	var path := data as String
	
	compiled_result = {}
	compiler_data = GrammarCompilerData.new()
	compiler_data.base_directory = data
	if not FileAccess.file_exists(path.path_join("main.json")):
		errors.append("Unfind main.json file.")
		return
	
	var main = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("main.json")))
	if not main is Dictionary:
		errors.append("Main data must be dictionary.")
		return
	
	if not _read_main(main):
		return
	
	compiler_data.main_file.set_data(compiled_result[ResultType.MAIN])
	if not _compile_grammar():
		return
	
	_set_is_valid(true)

# 读取 main 文件。
func _read_main(data : Dictionary) -> bool:
	var obj := GrammarMainCompiler.new()
	obj.compile(data)
	
	errors.append_array(obj.errors)
	if not obj.is_valid():
		return false
	
	compiled_result[ResultType.MAIN] = obj.get_result()
	return true

# 解析语法。
func _compile_grammar() -> bool:
	if not FileAccess.file_exists(compiler_data.get_file_path(GrammarMain.FileType.MAIN_PROCESS)):
		errors.append("Unfind main_process file.")
		return false
	elif not FileAccess.file_exists(compiler_data.get_file_path(GrammarMain.FileType.LAW)):
		errors.append("Unfind law file.")
		return false
	elif not FileAccess.file_exists(compiler_data.get_file_path(GrammarMain.FileType.ENTRY)):
		errors.append("Unfind entry file.")
		return false
	
	for i : int in range(2, -1, -1):
		if not _compile_grammar_tree(i):
			return false
	
	if not _compile_grammar_translation():
		return false
	return true

# 解析语法三兄弟。
func _compile_grammar_tree(index : int) -> bool:
	var nam : String
	var obj : BaseGrammarCompiler
	var path : String
	var data : Dictionary
	var json := JSON.new()
	
	match index:
		0 :
			nam = "Main Process file"
			obj = GrammarProcessCompiler.new()
			path = compiler_data.get_file_path(GrammarMain.FileType.MAIN_PROCESS)
		1 :
			nam = "Law file"
			obj = GrammarLawCompiler.new()
			path = compiler_data.get_file_path(GrammarMain.FileType.LAW)
		2 :
			nam = "Entry file"
			obj = GrammarEntryCompiler.new()
			path = compiler_data.get_file_path(GrammarMain.FileType.ENTRY)
	
	json.parse(FileAccess.get_file_as_string(path))
	if not _test_json(json, nam):
		return false
	if not _test_value_type(json.data, 1 << TYPE_DICTIONARY, nam):
		return false
	data = json.data
	obj.compiler_sync(self)
	
	pre_compile(data)
	obj.compile(data)
	errors.append_array(obj.errors)
	if not obj.is_valid():
		return false
	
	match index:
		0:
			compiled_result[ResultType.PROCESS] = obj.get_result()
		1:
			compiled_result[ResultType.LAW] = obj.get_result()
		2:
			compiled_result[ResultType.ENTRY] = obj.get_result()
	return true
# 解析翻译。始终返回 true，翻译错误照样也能跑。
func _compile_grammar_translation() -> bool:
	compiled_result[ResultType.TRANSLATION] = {}
	var path := compiler_data.get_file_path(GrammarMain.FileType.TRANSLATION)
	
	if path.is_empty():
		return true
	
	if not FileAccess.file_exists(path):
		errors.append("Unfind grammar-translation file.")
		return true
	
	var json := JSON.new()
	json.parse(FileAccess.get_file_as_string(path))
	if not _test_json(json, "Translation file"):
		return true
	if not _test_value_type(json.data, 1 << TYPE_DICTIONARY, "Translation file"):
		return true
	
	pre_compile(json.data)
	var obj := GrammarTranslationCompiler.new()
	obj.compiler_sync(self)
	obj.compile(json.data)
	
	errors.append_array(obj.errors)
	if obj.is_valid():
		compiled_result[ResultType.TRANSLATION] = obj.get_result()
	return true
