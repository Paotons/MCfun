class_name CoordsElement
extends MultiParamElement
## 多个轴。

## 轴的标签。
const COORD_TAG : PackedStringArray = ["x", "y", "z", "w"]
## 轴的大小。
var coord_size := 3

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	var colors : PackedColorArray = [edit.color_coord_x, edit.color_coord_y, edit.color_coord_z, edit.color_coord_w]
	for i in params.size():
		var coord := params[i]
		if coord == null: break
		result[coord.get_valid_start()] = {"color" : colors[i] if i < 3 else edit.color_number}
		result[coord.get_valid_end()] = {"color" : edit.color_default}
	return result
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : coords>" % [rule.get_description()]
	data.insert_texts.append_array(["~ ~ ~", "^ ^ ^"])
	return data
func get_column_code_completion_data(column : int, rule : ElementRule, _command : CommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	var idx := get_param_index_from_column(column)
	data.hint_string = "<%s : coords%s>" % [rule.get_description(), "_" + COORD_TAG[idx] if 0 <= idx and idx < COORD_TAG.size() else ""]
	if get_valid_size() - 1 <= idx and idx < coord_size - 1:
		data.insert_texts.append_array(["~", "^"])
		data.fill_inserted_update(true)
	return data

static func create(text : String, offset : int, size := 3) -> CoordsElement:
	var element := CoordsElement.new()
	
	element.coord_size = size
	
	var last_coord : CoordElement
	var start := offset
	for i in size:
		var sult := CoordElement.create(text, start)
		if sult.is_faild:
			element.create_error(start, "Not find valid coord for %d." % [i])
			break
		element.params.append(sult)
		if i != 0: element.split_flags.append(sult.get_valid_start() - offset)
		start = sult.get_valid_end()
		last_coord = sult
	
	if element.params[0] == null:
		element.is_faild = true
		return element
	
	element.string = text.substr(offset, last_coord.get_valid_end() - offset)
	element.string_offset = offset
	element.valid_start = element.params[0].get_valid_start() - offset
	element.is_faild = false
	return element


## 获取大小。
func get_size() -> int:
	return coord_size
## 获取可用的大小。
func get_valid_size() -> int:
	is_faild_assert()
	return params.size()
