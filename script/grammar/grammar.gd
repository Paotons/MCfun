class_name Grammar
extends Resource
## 语法。
##
## 支持不同版本。
## v1目录模式。[codeblock]
## {"files" : {"main_process" : false, "law" : false, "entry" : false}, "main" : false}
## [/codeblock]
enum ProcessType {
	## 普通。
	NORMAL = 0,
	## 本地。
	NATIVE = 1,
	## 注解。
	COMMENT = 2,
}

## 主文件数据。
var main : GrammarMain

## 目录路径。
var directory_path : String

## 主进程。
var main_process : GrammarProcess
## 本地进程。
var native_process := GrammarProcess.new()
## 注解进程。
var comment_process := GrammarProcess.new()
## 账目。
var entry : GrammarEntry
## 规则。
var law : GrammarLaw
## 翻译。
var translation : GrammarTranslation

#region 缓存。
# 指令列表类型。
var _cmd_list_types : PackedStringArray
#endregion

## 返回进程。
func get_process(idx := 0) -> GrammarProcess:
	match idx:
		ProcessType.NORMAL : return main_process
		ProcessType.NATIVE : return native_process
		ProcessType.COMMENT : return comment_process
		_ : return null
## 返回账目。
func get_entry(idx := 0) -> GrammarEntry:
	return entry if idx == 0 else null
## 返回规则。
func get_law(idx := 0) -> GrammarLaw:
	return law if idx == 0 else null
## 返回翻译器。
func get_translation() -> GrammarTranslation:
	return translation

func _clear() -> void:
	main_process = null
	law = null
	entry = null
	main = null

## 返回指令列表类型。
func get_cmd_list_types() -> PackedStringArray:
	return _cmd_list_types

# 返回指令列表类型。
func _get_cmd_list_types() -> PackedStringArray:
	var res : Dictionary[String, bool]
	var all : PackedStringArray
	all.append_array(main_process.get_cmd_list_tyes())
	all.append_array(native_process.get_cmd_list_tyes())
	all.append_array(comment_process.get_cmd_list_tyes())
	all.append_array(law.get_cmd_list_types())
	for i in all:
		res[i] = false
	return PackedStringArray(res.keys())

## 初始化完成，开始准备。[br]
## [b]注意：[/b]没有初始化过的语法会出现同步问题。
func ready() -> void:
	native_process._follow_translation(translation)
	comment_process._follow_translation(translation)
	main_process._follow_translation(translation)

#region 打开。
# 最后计算。
func _open_ending() -> PackedStringArray:
	var errors := _set_native_process()
	if not errors.is_empty():
		return errors
	errors = _set_comment_process()
	if not errors.is_empty():
		return errors
	_cmd_list_types = _get_cmd_list_types()
	return []

## 尝试打开，如果指定目录没有 [code].compiled[/code] 会解析该目录，再生成。
func try_open(path : String) -> PackedStringArray:
	var to_path := path.path_join(".compiled")
	var errors : PackedStringArray
	
	if DirAccess.dir_exists_absolute(to_path):
		errors = open(to_path)
		if not errors.is_empty():
			_clear()
			errors = compile(path, to_path)
	else:
		DirAccess.make_dir_absolute(to_path)
		errors = compile(path, to_path)
	ready()
	return errors

# HACK 没有返回错误。
## 打开文件夹。
func open(path : String) -> PackedStringArray:
	if not DirAccess.dir_exists_absolute(path):
		return ["Not find diractory \"%s\"." % path]
	elif not FileAccess.file_exists(path.path_join("main")):
		return ["Not find main file."]
	directory_path = path
	
	var data : Variant
	var errors : PackedStringArray
	
	var file := FileAccess.open(path.path_join("main"), FileAccess.READ)
	data = file.get_var()
	file.close()
	
	main = GrammarMain.new()
	errors = main.set_data(data)
	if not errors.is_empty():
		return errors
	
	match main.format_version:
		0 : pass
		1 : errors = _open_v1(path)
		_ : return ["Unvaild format_version %d." % main.format_version]
	
	if not errors.is_empty():
		return errors
	
	ready()
	return _open_ending()

@warning_ignore("unused_parameter")
func _open_v1(path : String) -> PackedStringArray:
	main.set_file_path(GrammarMain.FileType.MAIN_PROCESS, path.path_join("files/main_process"))
	main.set_file_path(GrammarMain.FileType.LAW, path.path_join("files/law"))
	main.set_file_path(GrammarMain.FileType.ENTRY, path.path_join("files/entry"))
	main.set_file_path(GrammarMain.FileType.TRANSLATION, path.path_join("files/translation"))
	
	if not FileAccess.file_exists(main.get_file_path(GrammarMain.FileType.MAIN_PROCESS)):
		return ["Not find main_process."]
	elif not FileAccess.file_exists(main.get_file_path(GrammarMain.FileType.LAW)):
		return ["Not find law."]
	elif not FileAccess.file_exists(main.get_file_path(GrammarMain.FileType.ENTRY)):
		return ["Not find entry."]
	
	main_process = GrammarProcess.new()
	law = GrammarLaw.new()
	entry = GrammarEntry.new()
	translation = GrammarTranslation.new()
	
	var data : Variant
	var file : FileAccess
	
	file = FileAccess.open(main.get_file_path(GrammarMain.FileType.MAIN_PROCESS), FileAccess.READ)
	data = file.get_var()
	file.close()
	main_process.set_data(data)
	
	file = FileAccess.open(main.get_file_path(GrammarMain.FileType.LAW), FileAccess.READ)
	data = file.get_var()
	file.close()
	law.set_data(data)
	
	file = FileAccess.open(main.get_file_path(GrammarMain.FileType.ENTRY), FileAccess.READ)
	data = file.get_var()
	file.close()
	entry.set_data(data)
	
	if FileAccess.file_exists(main.get_file_path(GrammarMain.FileType.TRANSLATION)):
		file = FileAccess.open(main.get_file_path(GrammarMain.FileType.TRANSLATION), FileAccess.READ)
		data = file.get_var()
		file.close()
		translation.set_data(data)
	return []
#endregion

## 解析，并把解析后的结果放入指定目录，返回错误信息。
func compile(path : String, to_path : String) -> PackedStringArray:
	directory_path = path
	
	if not DirAccess.dir_exists_absolute(path):
		return ["Not find directory."]
	
	if not DirAccess.dir_exists_absolute(to_path):
		return ["Not has target directory."]
	
	var compiler := GrammarCompiler.new()
	compiler.compile(path)
	if not compiler.errors.is_empty():
		return compiler.errors
	compiler.set_to_grammar(self)
	
	if entry == null:
		return ["Entry is null."]
	elif law == null:
		return ["Law is null."]
	elif main_process == null:
		return ["Process is null."]
	elif translation == null:
		return ["Translation is null."]
	
	_save_grammar(to_path)
	var errors := _open_ending()
	return errors

func _set_native_process() -> PackedStringArray:
	const COMPILED := "res://resource/native/compiled/process"
	
	assert(FileAccess.file_exists(COMPILED), "Not compiled process.")
	
	var file := FileAccess.open(COMPILED, FileAccess.READ)
	var data : Dictionary = file.get_var()
	file.close()
	
	native_process.set_data(data)
	return []
func _set_comment_process() -> PackedStringArray:
	const COMPILED := "res://resource/comment/compiled/process"
	
	assert(FileAccess.file_exists(COMPILED), "Not compiled process.")
	
	var file := FileAccess.open(COMPILED, FileAccess.READ)
	var data : Dictionary = file.get_var()
	file.close()
	
	comment_process.set_data(data)
	return []

#region 保存。
func _save_grammar(path : String) -> void:
	match  main.format_version:
		0 : return
		1 : _save_grammar_v1(path)
		_ : push_error("Unkonw version.")

func _save_grammar_v1(path : String) -> void:
	var file : FileAccess
	
	file = FileAccess.open(path.path_join("main"), FileAccess.WRITE)
	file.store_var(main.get_data())
	file.close()
	
	var files_dir := path.path_join("files")
	if not DirAccess.dir_exists_absolute(files_dir):
		DirAccess.make_dir_absolute(files_dir)
	
	file = FileAccess.open(files_dir.path_join("translation"), FileAccess.WRITE)
	file.store_var(translation.get_data())
	file.close()
	
	file = FileAccess.open(files_dir.path_join("entry"), FileAccess.WRITE)
	file.store_var(entry.main_data)
	file.close()
	
	file = FileAccess.open(files_dir.path_join("law"), FileAccess.WRITE)
	file.store_var(law.get_data())
	file.close()
	
	file = FileAccess.open(files_dir.path_join("main_process"), FileAccess.WRITE)
	file.store_var(main_process.get_data())
	file.close()
#endregion
