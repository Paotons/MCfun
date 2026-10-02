class_name GrammarMainCompiler
extends BaseGrammarCompiler
## 语法主文件解析器。

## 必要的样本。
const _ESSENT_EXAMPLE_V1 := {
	"files" : {
		"process" : 1 << TYPE_STRING,
		"law" : 1 << TYPE_STRING,
		"entry" : 1 << TYPE_STRING,
	}
}

## 元素类型。
enum MetaType {
	FORMAT_VERSION = 0,
	FILES = 1,
}

## 文件类型。
enum FileType {
	## 主进程。
	MAIN_PROCESS = 0,
	## 规则。
	LAW = 1,
	## 章类。
	ENTRY = 2,
	## 翻译。
	TRANSLATION = 3,
}

func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("Main_data should be dictionary, but is %s." % type_string(typeof(data)))
		return
	compiled_result = {0 : -1}
	
	var from := data as Dictionary
	if not from.has("format_version"):
		errors.append("Main_data not has format_version.")
		return
	elif not from["format_version"] is float:
		errors.append("Main_data[format_version] should be int.")
		return
	
	var version := data["format_version"] as int
	compiled_result[MetaType.FORMAT_VERSION] = version
	
	match version:
		1:
			_set_is_valid(_compile_v1(data))
		_:
			errors.append("Main_data unvaild format_version %d." % from.format_version)
			return

func _compile_v1(data : Dictionary) -> bool:
	if not _test_dictionary_from_example(data, _ESSENT_EXAMPLE_V1, "Main_data"):
		return false
	
	var files : Dictionary
	files[FileType.MAIN_PROCESS] = data["files"]["process"]
	files[FileType.LAW] = data["files"]["law"]
	files[FileType.ENTRY] = data["files"]["entry"]
	
	files[FileType.TRANSLATION] = data["files"].get("translation", "")
	
	compiled_result[MetaType.FILES] = files
	return true
