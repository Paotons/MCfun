class_name MCFunctionCoperWindow
extends Window
## 函数复制窗口。
##
## 帮助复制函数的窗口。

## 函数内容。
var _fun_string : PackedStringArray

func _ready() -> void:
	update_control()

func _get_path_line_edit() -> LineEdit:
	return $MarginContainer/VBoxContainer/HBoxContainer/Path
func _get_file_path() -> String:
	return _get_path_line_edit().get_text()
# 获取信息标签。
func _get_inform_label() -> Label:
	return $MarginContainer/VBoxContainer/Inform
# 获取复制一行的按钮。
func _get_copy_oneline_button() -> Button:
	return $MarginContainer/VBoxContainer/HBoxContainer5/CopyOneLine
# 获取正常复制到按钮。
func _get_copy_normal_button() -> Button:
	return $MarginContainer/VBoxContainer/HBoxContainer5/CopyNormal
# 获取文件选项按钮。
func _get_file_option_button() -> OptionButton:
	return $MarginContainer/VBoxContainer/HBoxContainer2/FileOptionButton
# 获取行偏移盒子。
func _get_line_offset_box() -> SpinBox:
	return $MarginContainer/VBoxContainer/HBoxContainer3/LineOffset
# 获取行长度盒子。
func _get_line_length_box() -> SpinBox:
	return $MarginContainer/VBoxContainer/HBoxContainer4/LineLength
# 获取偏移。
func _get_line_offset() -> int:
	return int(_get_line_offset_box().value)
# 获取行长度。
func _get_line_length() -> int:
	return int(_get_line_length_box().value)
# 设置按钮禁用状态。
func _set_button_disabled(enabled : bool) -> void:
	_get_copy_normal_button().disabled = enabled
	_get_copy_oneline_button().disabled = enabled
# 设置禁用状态。
func set_disabled(enabled : bool) -> void:
	_set_button_disabled(enabled)
	var offset_box := _get_line_offset_box()
	offset_box.value = 0.0
	offset_box.max_value = 0.0
	offset_box.min_value = 0.0
	_get_file_option_button().get_parent_control().hide()

# 更新选项按钮，如果失败返回 true。
func _update_option() -> bool:
	var path := _get_file_path()
	var button := _get_file_option_button()
	
	if path.get_extension() == "zip":
		button.get_parent_control().show()
		button.clear()
		
		var file := ZIPReader.new()
		file.open(path)
		for child in file.get_files():
			if child.get_extension() == "mcfunction":
				button.add_item(child.get_basename())
		file.close()
		
		if button.item_count == 0:
			return true
		else:
			button.set_block_signals(true)
			button.select(0)
			button.set_block_signals(false)
			return false
	else:
		button.clear()
		button.get_parent_control().hide()
		return false

## 检查一下路径，如果有问题返回 [code]true[/code]。
func test_path() -> bool:
	var path := _get_file_path()
	var label := _get_inform_label()
	
	if path.is_empty():
		label.add_theme_color_override("font_color", Color.RED)
		label.text = "空路径。"
		return true
	
	if not (path.is_absolute_path() or path.is_relative_path()):
		label.add_theme_color_override("font_color", Color.RED)
		label.text = "路径无效。"
		return true
	
	var extension := path.get_extension()
	if not (extension == "mcfunction" or extension == "zip"):
		label.add_theme_color_override("font_color", Color.RED)
		label.text = "文件格式需要为mcfunction或者是zip格式。"
		return true
	
	if not FileAccess.file_exists(path):
		label.add_theme_color_override("font_color", Color.RED)
		label.text = "文件不存在。"
		return true
	
	label.add_theme_color_override("font_color", Color.GREEN)
	label.text = "文件有效。"
	return false

## 更新函数内容，要求路径有效。
func update_fun_string() -> void:
	var path := _get_file_path()
	var extension := path.get_extension()
	
	if extension == "zip":
		var file := ZIPReader.new()
		file.open(path)
		
		var button := _get_file_option_button()
		var child := button.get_item_text(button.selected) + ".mcfunction"
		_fun_string = file.read_file(child).get_string_from_utf8().split("\n", false)
		file.close()
	else:
		_fun_string = FileAccess.get_file_as_string(path).split("\n", false)
	
	_get_line_offset_box().max_value = _fun_string.size()
	_get_line_offset_box().min_value = 1
## 更新信息，要求路径有效，有字符串。
func update_file_inform() -> void:
	var label := _get_inform_label()
	
	if _fun_string.size() == 0:
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.text = "文件有效。\n空文件。"
		_set_button_disabled(true)
	else:
		label.add_theme_color_override("font_color", Color.GREEN)
		label.text = "文件有效。\n总计 %d 条指令" % [_fun_string.size()]
		_set_button_disabled(false)

## 更新界面。
func update_control() -> void:
	_fun_string.clear()
	if test_path():
		set_disabled(true)
		return
	
	if _update_option():
		set_disabled(true)
		return
	update_fun_string()
	update_file_inform()

func _on_path_text_changed(_new_text: String) -> void:
	update_control()

func _on_file_option_button_item_selected(_index: int) -> void:
	update_fun_string()
	update_file_inform()

func _on_copy_one_line_pressed() -> void:
	var box := _get_line_offset_box()
	var from := int(box.value)
	DisplayServer.clipboard_set(_fun_string[from - 1])
	box.value = float(mini(from + 1, _fun_string.size()))

func _on_copy_normal_pressed() -> void:
	var box := _get_line_offset_box()
	var from := int(box.value)
	var to := mini(from + _get_line_length(), _fun_string.size() + 1)
	for i in range(from - 1, to -1):
		await get_tree().process_frame
		DisplayServer.clipboard_set(_fun_string[i])
	box.value = float(mini(to, _fun_string.size()))
