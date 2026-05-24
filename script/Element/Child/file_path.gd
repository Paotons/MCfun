class_name FilePathElement
extends BaseStringElement

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return super._get_highlight(edit)
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	var path := ProjectManager.get_current_project().get_project_config().get_project_path()
	var paths := FileSystem.get_directory_files(path, rule.get_file_path_extensions())
	
	if not rule.is_file_path_using_extension():
		_map_file_path_to_basename(paths)
	
	data.insert_texts.append_array(paths)
	data.fill_insert_mode(FunctionCompletionData.InsertMode.STRING)
	return data
func _get_column_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	var path := ProjectManager.get_current_project().get_project_config().get_project_path()
	var paths := FileSystem.get_directory_files(path, rule.get_file_path_extensions())
	
	if not rule.is_file_path_using_extension():
		_map_file_path_to_basename(paths)
	
	data.insert_texts.append_array(paths)
	data.fill_insert_mode(FunctionCompletionData.InsertMode.STRING)
	return data

static func create(text : String, offset : int, _rule : ElementRule = null) -> FilePathElement:
	var element := FilePathElement.new()
	StringElement._create_string_element(element, text, offset)
	if element.is_faild:
		return element
	return element

# 去除文件的扩展名。
static func _map_file_path_to_basename(paths : PackedStringArray) -> void:
	for i in paths.size():
		paths[i] = paths[i].get_basename()
