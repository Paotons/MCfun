class_name CoordElement
extends BaseStringElement
## 轴。

## 轴的模式。
enum CoordMode {
	## 定值。
	CONST,
	## 相对。
	RELATIVE,
	## 局部。
	LOCAL,
}

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_number}, get_valid_end() : {"color" : edit.color_default}}
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.insert_texts.append_array(["~", "^"])
	data.hint_string = "<%s : coord>" % rule.get_description()
	return data
func _get_column_code_completion_data(_column : int, rule : ElementRule, _command : BaseCommandElement) -> FunctionCompletionData:
	var data := FunctionCompletionData.new()
	data.insert_texts.append_array(["~", "^"])
	data.hint_string = "<%s : coord>" % rule.get_description()
	return data

static func create(text : String, offset : int) -> CoordElement:
	var element := StringElement._create_string_element(CoordElement.new(), text, offset) as CoordElement
	
	if element.is_faild:
		return element
	
	var valid_str := element.get_valid_string()
	
	if is_coord(valid_str):
		element.is_faild = false
		return element
	
	var num_start := 0
	var is_const := true
	if valid_str[0] == "~" or valid_str[0] == "^":
		num_start += 1
		is_const = false
	
	var i := 0
	i = valid_str.length() - 1
	while i >= num_start:
		var chr_ord := ord(valid_str[i])
		if chr_ord == 46 or 48 <= chr_ord and chr_ord <= 57:
			if valid_str.substr(num_start, i - num_start + 1).is_valid_float():
				element.string = text.substr(offset, element.valid_start + num_start + i)
				element.is_faild = false
				return element
		i -= 1
	
	if not is_const:
		element.string = text.substr(offset, element.valid_start + num_start + i)
		
		element.is_faild = false
		return element
	else:
		element.string = ""
		element.create_error(text.length(), "Not find coord.")
		element.is_faild = true
		return element

## 判断是否为坐标字符串。
static func is_coord(text : String) -> bool:
	if text.is_empty():
		return false
	var mode := CoordMode.RELATIVE if text.begins_with("~") else CoordMode.LOCAL if text.begins_with("^") else CoordMode.CONST
	var num := text.substr(1 if mode != CoordMode.CONST else 0)
	if num.is_empty():
		return true
	if num.is_valid_float():
		if num.find("e") == -1:
			return true
		else:
			return false
	else:
		return false
## 获取轴的模式。
func get_coord_mode() -> int:
	is_faild_assert()
	var vaild := get_valid_string()
	return _get_coord_mode(vaild)

## 获取偏移量。
func get_offset_value() -> float:
	var text := get_valid_string()
	if text.begins_with("~") or text.begins_with("^"):
		var t := text.substr(1)
		return 0.0 if t.is_empty() else t.to_float()
	else:
		return text.to_float()

## 根据偏移量和模式，构建字符串，并返回。
static func create_coord_string(offset : float, mode := CoordMode.CONST) -> String:
	if mode == CoordMode.CONST:
		return str(offset)
	else:
		return "%s%s" % ["~" if mode == CoordMode.LOCAL else "^" if mode == CoordMode.RELATIVE else "", "" if is_zero_approx(offset) else str(offset)]
## 根据偏移量和模式，构建图块字符串，并返回。
static func create_tile_coord_string(offset : int, mode := CoordMode.CONST) -> String:
	if mode == CoordMode.CONST:
		return str(offset)
	else:
		return "%s%s" % ["~" if mode == CoordMode.LOCAL else "^" if mode == CoordMode.RELATIVE else "", "" if offset == 0 else str(offset)]

# 仅根据头判断类型。
static func _get_coord_mode(text : String) -> CoordMode:
	if text.begins_with("~"):
		return CoordMode.LOCAL
	elif text.begins_with("^"):
		return CoordMode.RELATIVE
	else:
		return CoordMode.CONST
