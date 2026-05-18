class_name EditBaseControl
extends Control
## 编辑器基节点。

## 保存场景。
signal save_scene

func _get_function_edit() -> FunctionEdit:
	return $Base/HSplitContainer/VBoxContainer2/FunctionEdit
func _get_file_list_container() -> FileListContainer:
	return $Base/HSplitContainer/FileList/MarginContainer/FileListContainer
func _get_loading_title_label() -> Label:
	return $Loading/VBoxContainer/Title
func _get_loading_process_label() -> Label:
	return $Loading/VBoxContainer/Process
func _get_loading_panel() -> Panel:
	return $Loading

## 退出到项目列表。
func exit_to_project_list(saving := true) -> void:
	if saving:
		save_scene.emit()
	
	ProjectManager.get_current_project().get_project_config().update_project_nearest_time()
	ProjectManager.current_project = null
	
	get_tree().change_scene_to_file.call_deferred("uid://cbhgotylj3fjg")
## 重新加载当前场景。
func reload_scene(saving := true) -> void:
	if saving:
		save_scene.emit()
	
	var nam := ProjectManager.get_current_project().get_project_config().get_project_name()
	ProjectManager.current_project = ProjectManager.get_project(nam)
	
	get_tree().reload_current_scene.call_deferred()

## 显示正在加载。
func show_loading() -> void:
	_get_loading_panel().show()
## 隐藏真正加载。
func hide_lading() -> void:
	_get_loading_panel().hide()
## 设置正在加载。
func set_loading(title : String, process : String) -> void:
	_get_loading_title_label().set_text(title)
	_get_loading_process_label().set_text(process)

func _on_project_menu_button_exit_scene() -> void:
	exit_to_project_list(true)

func _on_project_menu_button_reload_scene() -> void:
	reload_scene(true)

func _on_project_setting_reload_project() -> void:
	reload_scene(true)
