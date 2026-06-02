class_name EditBaseControl
extends Control
## 编辑器基节点。

## 保存场景。
signal save_scene

static var _base_control : EditBaseControl

func _ready() -> void:
	_base_control = self

func _exit_tree() -> void:
	_base_control = null

## 返回当前编辑器控件。
static func get_base_control() -> EditBaseControl:
	return _base_control
## 如果真正处于编辑模式，返回 [code]true[/code]。
static func is_editing() -> bool:
	return _base_control != null

## 返回函数的文本编辑器。
func get_function_edit() -> FunctionEdit:
	return $Base/HSplitContainer/VBoxContainer2/FunctionEdit
## 返回文件列表容器。
func get_file_list_container() -> FileListContainer:
	return $Base/HSplitContainer/FileList/MarginContainer/FileListContainer
## 返回自动保存的计时器。
func get_auto_saving_timer() -> Timer:
	return $AutoSaveingTimer

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

## 保存场景。
func save_tree() -> void:
	save_scene.emit()
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

func _on_edit_setting_reload_scene() -> void:
	reload_scene(true)

func _on_error_window_confirmed() -> void:
	exit_to_project_list(false)

func _on_auto_saveing_timer_timeout() -> void:
	save_tree()
	get_file_list_container().save_all_file()
