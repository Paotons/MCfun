class_name BacketElement
extends StringElement
## 普通括号。
##
## 所有括号类的基类。


## 起始括号。
var start_backet := "{"
## 结束括号。
var end_backet := "}"

## 虚函数，返回括号类别。
func _get_backet_type() -> int:
	return BacketElementManager.Type.NORMAL
static func create(text : String, offset : int, start := "{", end := "}") -> BacketElement:
	return _create_backet_element(BacketElement.new(), text, offset, start, end)

## 这个类应该是 [code]protected[/code]，基于在初始括号上创建，对于括号的扩展特别有帮助。
static func _create_backet_element(element : BacketElement, text : String, offset : int, start : String, end : String) -> BacketElement:
	if start == end:
		return _create_backet_for_same_sign(element, text, offset, start)
	
	element.string_offset = offset
	element.start_backet = start
	element.end_backet = end
	
	var result := StringElement.create(text, offset)
	if result.is_faild:
		element.create_error(offset, "Not find any string.")
		return element
	
	var valid_str := result.get_valid_string()
	if not valid_str.begins_with(start):
		element.create_error(result.get_valid_start(), "Not begin with %s." % [start])
		return element
	element.valid_start = result.valid_start
	
	var length := text.length()
	var backet := PackedInt32Array([result.get_valid_start()])
	var size := 1
	var in_string := false
	var i := result.get_valid_start() + 1
	while i < length:
		match text[i]:
			start:
				if not in_string:
					size += 1
					backet.append(i)
			end:
				if not in_string:
					size -= 1
					backet.remove_at(size)
					if size == 0: break
			"\"":
				in_string = not in_string
			"\\":
				i += 1
		i += 1
	
	if not backet.is_empty():
		element.create_error(i, "Not find end backet called \"%s\"." % [end])
	
	element.string = text.substr(offset, i - offset + 1)
	element.is_faild = false
	return element
# 创建对于的起始括号和终点括号一样的。
static func _create_backet_for_same_sign(element : BacketElement,text : String, offset : int, sign_string := "\"") -> BacketElement:
	element.string_offset = offset
	element.start_backet = sign_string
	element.end_backet = sign_string
	
	var result := StringElement.create(text, offset)
	if result.is_faild:
		element.create_error(offset, "Not find any string.")
		return element
	var valid_str := result.get_valid_string()
	
	if not valid_str.begins_with(sign_string):
		element.create_error(result.get_valid_start(), "Not begin with quotation.")
		return element
	element.valid_start = result.get_valid_start() - offset
	
	var length := text.length()
	var start := result.get_valid_start()
	while start < length:
		start = text.find(sign_string, start + 1)
		if start == -1:
			element.create_error(element.valid_start + offset, "Not find brother backet.")
			element.string = text.substr(offset)
			element.is_faild = false
			return element
		else:
			if ord(text[start - 1]) == 92: # 前面有转义
				continue
			else:
				element.string = text.substr(offset, start - offset + 1)
				element.is_faild = false
				return element
	breakpoint # 根本不会到这里来
	return null

## 获取括号类别。
func get_backet_type() -> int:
	return _get_backet_type()

## 获取括号包括的内容开头位置。
func get_backet_string_start() -> int:
	is_faild_assert()
	return get_valid_start() + 1
## 获取括号包括的内容结束位置。
func get_backet_string_end() -> int:
	if is_faild:
		push_error("The result is faild, but get something.")
		return -1
	return get_valid_end() - (1 if string.ends_with(end_backet) else 0)
## 获取括号里的内容。
func get_backeted_string() -> String:
	if is_faild:
		push_error("The result is faild, but get something.")
		return ""
	return string.substr(string.find(start_backet) + 1, string.length() - 2 if string.ends_with(end_backet) else -1)
## 如果括号中的字符串为空，返回 [code]true[/code]。
func is_backet_string_empty() -> bool:
	is_faild_assert()
	return valid_start == get_backet_string_end() - 1

## 括号如果闭合，返回 [code]true[/code]。
func is_closed() -> bool:
	if is_faild:
		push_error("The result is faild, but get something.")
		return false
	return string.ends_with(end_backet) and not string.ends_with("\\" + end_backet)

## 如果列包含在括号中，返回 [code]true[/code]。
func has_backet_column(column : int) -> bool:
	is_backet_string_empty()
	return column >= get_backet_string_start() and column <= get_backet_string_end()
## 如果两个括号首尾一样，返回 [code]true[/code]。
func is_same_backet() -> bool:
	if is_faild:
		push_error("The result is faild, but get something.")
		return false
	return start_backet == end_backet


