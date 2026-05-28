class_name CoordsElement
extends MultiParamElement
## 多个轴。
##
## 一般用于表示坐标。

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
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.hint_string = "<%s : coords>" % [rule.get_description()]
	data.insert_texts.append_array(["~ ~ ~", "^ ^ ^"])
	return data
func get_column_code_completion_data(column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
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
	
	if element.params.is_empty():
		element.is_faild = true
		return element
	
	element.string = text.substr(offset, last_coord.get_valid_end() - offset)
	element.string_offset = offset
	element.valid_start = element.params[0].get_valid_start() - offset
	element.is_faild = false
	return element

## 返回轴。
func get_coord(idx : int) -> CoordElement:
	return get_param(idx)
## 获取大小。
func get_size() -> int:
	return coord_size
## 获取可用的大小。
func get_valid_size() -> int:
	is_faild_assert()
	return params.size()

## 获取矩形，失败返回空矩形。
func get_aabb(a : CoordsElement) -> AABB:
	if get_valid_size() != 3 or not get_valid_size() != a.get_valid_size():
		return AABB()
	var aabb : AABB
	
	for i in 3:
		var x := get_coord(i)
		var y := get_coord(i)
		
		if x.get_coord_mode() != y.get_coord_mode():
			return AABB()
		
		aabb.position[i] = x.get_offset_value()
		aabb.end[i] = y.get_offset_value()
	aabb.abs()
	return aabb
## 获取图块矩形。
func get_tile_aabb(a : CoordsElement) -> AABB:
	if get_valid_size() != 3 or get_valid_size() != a.get_valid_size():
		return AABB()
	var aabb : AABB
	
	for i in 3:
		var x := get_coord(i)
		var y := a.get_coord(i)
		
		if x.get_coord_mode() != y.get_coord_mode():
			return AABB()
		
		aabb.position[i] = floori(x.get_offset_value())
		aabb.end[i] = roundi(y.get_offset_value() + 1.0)
	aabb.abs()
	return aabb

## 根据偏移和模式构建坐标。
static func create_coords_string(offset : Vector3, x := CoordElement.CoordMode.CONST, y := CoordElement.CoordMode.CONST, z := CoordElement.CoordMode.CONST) -> String:
	return "%s %s %s" % [CoordElement.create_coord_string(offset.x, x), CoordElement.create_coord_string(offset.y, y), CoordElement.create_coord_string(offset.z, z)]
## 根据偏移和模式构建图块坐标。
static func create_tile_coords_string(offset : Vector3i, x := CoordElement.CoordMode.CONST, y := CoordElement.CoordMode.CONST, z := CoordElement.CoordMode.CONST) -> String:
	return "%s %s %s" % [CoordElement.create_tile_coord_string(offset.x, x), CoordElement.create_tile_coord_string(offset.y, y), CoordElement.create_tile_coord_string(offset.z, z)]

