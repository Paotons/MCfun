class_name PointPathElement
extends MultiParamElement
## 点号路径元素。
##
## 类似于 [code]xxx.xxx.xxx[/code]。

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	result[get_valid_start()] = {"color" : edit.color_point_path_mumber}
	for split in split_flags:
		result[split + string_offset] = {"color" : edit.color_default}
		result[split + string_offset + 1] = {"color" : edit.color_point_path_mumber}
	result[get_valid_end()] = {"color" : edit.color_default}
	return result
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : point_path>" % [rule.get_description()]
	var chapter := rule.get_point_path_chapter() as GrammerPathChapter
	for path in chapter.get_paths():
		data.insert_texts.append(".".join(path))
	data.fill_insert_mode(CodeCompletionData.InsertMode.POINT_PATH)
	return data
func _get_column_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : point_path>" % [rule.get_description()]
	var chapter := rule.get_point_path_chapter() as GrammerPathChapter
	for path in chapter.get_paths():
		data.insert_texts.append(".".join(path))
	data.fill_insert_mode(CodeCompletionData.InsertMode.POINT_PATH)
	return data

static func create(text : String, offset : int, rule : ElementRule = null) -> PointPathElement:
	var element := _create_string_element(PointPathElement.new(), text, offset) as PointPathElement
	
	if element.is_faild:
		return element
	
	var valid_str := element.get_valid_string()
	var valid_off := element.valid_start
	var length := valid_str.length()
	var index := 0
	var path : PackedStringArray
	while index < length:
		var i := valid_str.find(".", index)
		if i == -1:
			i = length
		else:
			element.split_flags.append(valid_off + i)
		var result := StringElement.create(text.substr(0, offset + valid_off + i), offset + valid_off + index)
		path.append(result.get_valid_string())
		element.params.append(null if result.is_faild else result)
		index += i + 1
	if valid_str.ends_with("."):
		element.params.append(null)
		path.append("")
		element.create_error(element.get_valid_end(), "Cant end with \".\".")
	
	var chapter := rule.get_point_path_chapter() as GrammerPathChapter
	if not chapter.has_path(path):
		element.create_error(offset, "Not has the path.")
	return element

## 获取路径。
func get_path() -> PackedStringArray:
	is_faild_assert()
	var res : PackedStringArray
	for param : StringElement in params:
		res.append(param.get_valid_string())
	return res

## 获取点号路径的开头，仅限单词。
static func rfind_point_path(text : String, idx : int) -> int:
	var res := idx
	while res >= 0:
		res = StrT.rfind_unletter(text, res)
		if res < 0: return res
		
		if text[res] == ".":
			res -= 1
		else: return res + 1
	return -1
## 获取点号路径的结尾，仅限单词。
static func find_point_path(text : String, idx : int) -> int:
	var res := idx
	var length := text.length()
	while res < length:
		res = StrT.find_unletter(text, res)
		if res >= length: return res
		
		if text[res] == ".":
			res += 1
			if res == length: return length
		else: return length if res == -1 else res
	return -1
## 获取点号路径，仅限单词。
static func find_point_path_string(text : String, idx : int) -> String:
	var star := rfind_point_path(text, idx - 1)
	var end := find_point_path(text, idx)
	return "" if star == -1 or end == -1 else text.substr(star, end - star)
