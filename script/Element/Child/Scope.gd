class_name ScopeElement
extends DoubleParamElement
## 范围元素。
##
## 键为较小值，值为较大值。

## 标志性符号起始位置。
var flag_start := -1

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	if has_key():
		result.merge({get_key_start() : {"color" : edit.color_number}, get_key_end() : {"color" : edit.color_default}})
	if has_value():
		result.merge({get_value_start() : {"color" : edit.color_number}, get_value_end() : {"color" : edit.color_default}})
	return result

static var _scope_searched_regex := RegEx.create_from_string(r"^(?<start> *)(?=\d|.*\d)(?<min>[+\-]?\d+)?(?<flag>\.+)?(?<max>[+\-]?\d+)?")
static func create(text : String, offset : int) -> ScopeElement:
	var element := ScopeElement.new()
	element.string_offset = offset
	
	var result := _scope_searched_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find scope.")
		return element
	element.valid_start = result.get_end("start")
	
	element.key_start = result.get_start("min")
	element.key_end = result.get_end("min")
	
	element.flag_start = result.get_end("flag")
	if element.flag_start != -1:
		var flag := result.get_string("flag")
		if flag.length() != 2:
			element.create_error(element.flag_start, "The flag \".\" has cunted %d." % [flag.length()])
			return element
	element.value_start = result.get_start("max")
	element.value_end = result.get_end("max")
	
	element.string = result.get_string()
	element.is_faild = false
	return element

## 判断字符是否为范围类型。
static func is_valid_scope(text : String) -> bool:
	var flag := text.find("..")
	if flag == -1:
		return false
	var start := text.substr(0, flag)
	var end := text.substr(flag + 2)
	var startv := start.is_valid_int()
	var endv := end.is_valid_int()
	if startv:
		if endv: return true
		elif end.is_empty(): return true
	elif start.is_empty():
		if endv: return true
	return false


