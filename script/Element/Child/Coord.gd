class_name CoordElement
extends StringElement
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

func _get_hightlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	return {get_valid_start() : {"color" : edit.color_number}, get_valid_end() : {"color" : edit.color_default}}

static func create(text : String, offset : int) -> CoordElement:
	var element := _create_string_element(CoordElement.new(), text, offset) as CoordElement
	
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
	return -1 if not is_coord(vaild) else _get_coord_mode(vaild)

# 仅根据头判断类型。
static func _get_coord_mode(text : String) -> CoordMode:
	if text.begins_with("~"):
		return CoordMode.LOCAL
	elif text.begins_with("^"):
		return CoordMode.RELATIVE
	else:
		return CoordMode.CONST
