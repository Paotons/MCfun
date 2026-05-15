class_name FileListContainer
extends VBoxContainer
## 管理文件列表的容器。

## 选中的文件发生改变。
signal selected_changed(path : String)
## 保存文件时发出。
signal saved(path : String)
## 关闭文件时发出。
signal closed(path : String)

class _File extends Resource:
	var path : String
	var has_saved := true
	
	@warning_ignore("shadowed_variable")
	static func create(path : String, has_saved := true) -> _File:
		var f := _File.new()
		f.path = path
		f.has_saved = has_saved
		return f
	
	func get_display_text() -> String:
		return path.get_file() + ("(*)" if not has_saved else "")

## 当前选中的文件。
var selected_index : int
# 按钮组。
var _button_group := ButtonGroup.new()
# 所有文件。
var _files : Array[_File]
# 撤销与重做。
var _undo_redo := UndoRedo.new()

func _ready() -> void:
	_button_group.pressed.connect(_on_button_group_pressed)

func _on_button_group_pressed(button : BaseButton) -> void:
	var index := button.get_index()
	selected_changed.emit(_files[index].path)

#region API。
## 撤销。
func undo() -> void:
	if _undo_redo.has_undo():
		_undo_redo.undo()
## 重做。
func redo() -> void:
	if _undo_redo.has_redo():
		_undo_redo.redo()

## 打开文件。
func open_file(path : String) -> void:
	if is_file_opend(path):
		var index := _get_file_index(path)
		_select_file(index)
		return
	_undo_redo.create_action("open file")
	_undo_redo.add_do_method(_open_file.bind(path))
	
	_undo_redo.add_undo_method(_close_file.bind(path))
	_undo_redo.commit_action()
## 批量打开文件。
func open_multifile(paths : PackedStringArray) -> void:
	_undo_redo.create_action("open multifile")
	_undo_redo.add_do_method(_open_multifile.bind(paths))
	
	_undo_redo.add_undo_method(_close_multifile.bind(paths))
	_undo_redo.commit_action()
## 关闭文件。
func close_file(path : String) -> void:
	_undo_redo.create_action("close file")
	_undo_redo.add_do_method(_close_file.bind(path))
	
	_undo_redo.add_undo_method(_open_file.bind(path))
	_undo_redo.commit_action()
## 清除文件。
func clear_file() -> void:
	_undo_redo.create_action("clear file")
	_undo_redo.add_do_method(_close_multifile.bind(_files))
	
	_undo_redo.add_undo_method(_open_multifile.bind(_files))
	_undo_redo.commit_action()

## 返回所有文件。
func get_files() -> PackedStringArray:
	var result : PackedStringArray
	for file in _files:
		result.append(file.path)
	return result

## 如果有文件已打开，返回 [code]true[/code]。
func is_file_opend(path : String) -> bool:
	return _get_file_index(path) != -1
## 获取当前选中的文件。
func get_selected() -> String:
	if get_child_count() == 0:
		return ""
	var index := _button_group.get_pressed_button().get_index()
	return _files[index].path

## 设置文件保存状态。
func set_file_saved_state(path : String, enabled := true) -> void:
	var index := _get_file_index(path)
	if index == -1:
		push_error("Dont open file.")
		return
	_files[index].has_saved = enabled
	_update_file_button(index)
## 如果文件已保存，返回 [code]true[/code]。
func is_file_saved(path : String) -> bool:
	var index := _get_file_index(path)
	if index == -1:
		push_error("Dont open file.")
		return false
	return _files[index].has_saved
## 保存文件。
func save_file(path : String) -> void:
	var index := _get_file_index(path)
	if index == -1:
		return
	_save_file(index)
## 保存所有文件。
func save_all_file() -> void:
	for i in _files.size():
		_save_file(i)
#endregion

#region 文件执行函数。
func _open_file(path : String) -> void:
	_files.append(_File.create(path))
	_add_file_button()
	_select_file(_files.size() - 1)
func _open_multifile(paths : PackedStringArray) -> void:
	var last_index := -1
	for path in paths:
		last_index = _files.size()
		if is_file_opend(path): continue
		
		_files.append(_File.create(path))
		_add_file_button()
	
	if not last_index == -1:
		_select_file(last_index)
func _close_file(path : String) -> void:
	var index := _get_file_index(path)
	if _files[index].has_saved:
		_remove_file_button(index)
		_files.remove_at(index)
		closed.emit(path)
	else:
		_select_file(index)
		_get_file_save_option_window().popup_centered_clamped()
func _close_multifile(paths : PackedStringArray) -> void:
	for path in paths:
		var index := _get_file_index(path)
		if _files[index].has_saved:
			_remove_file_button(index)
			_files.remove_at(index)
			closed.emit(path)
		else:
			_select_file(index)
			_get_file_save_option_window().popup_centered_clamped()
			return
# 选中路径。
func _select_file(index : int) -> bool:
	if index == -1:
		return false
	var button := get_child(index) as Button
	button.button_pressed = true
	selected_index = index
	selected_changed.emit(_files[index].path)
	return true
# 保存文件。
func _save_file(index : int) -> void:
	if _files[index].has_saved:
		return
	saved.emit(_files[index].path)
	_files[index].has_saved = true
	_update_file_button(index)
#endregion

#region 文件工具。
# 获取文件序列。
func _get_file_index(path : String) -> int:
	return _files.find_custom(_is_file_path.bind(path))
# 如果文件路径为 path，返回 true。
func _is_file_path(file : _File, path : String) -> bool:
	return file.path == path

# 给文件加上按钮。
func _add_file_button(index : int = -1) -> void:
	var button := Button.new()
	button.text = _files[index].get_display_text()
	button.toggle_mode = true
	button.button_group = _button_group
	add_child(button)
# 移除文件按钮。
func _remove_file_button(index : int) -> void:
	var button := get_child(index) as Button
	button.queue_free()
	
	if button.button_pressed:
		await get_tree().process_frame
		if get_child_count() > 0:
			_select_file(maxi(0, index - 1))
		else:
			selected_changed.emit("")
# 更新文件按钮的显示。
func _update_file_button(index : int) -> void:
	var button := get_child(index) as Button
	button.text = _files[index].get_display_text()
#endregion

#region 文件选择保存的窗口。
# 显示文件保存的选择窗口。
func _get_file_save_option_window() -> Window:
	return $"../../../../../FileSaveOptionWindow"
func _on_file_save_option_window_close() -> void:
	var path := get_selected()
	save_file(path)
	close_file(path)
func _on_file_save_option_window_save_and_close() -> void:
	close_file(get_selected())
#endregion
