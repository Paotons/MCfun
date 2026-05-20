class_name ProjectExportSettingWindow
extends AcceptDialog
## 项目导出设置窗口。

## 导出线程。
var export_thread : Thread
## 导出设置。
var export_setting : ProjectExportSetting

func _ready() -> void:
	set_process(false)
	add_cancel_button("关闭")
	confirmed.connect(export_project)
	test_path()

## 关闭。
func close() -> void:
	if export_thread != null:
		export_thread = null
		export_setting = null
		_get_exporting_panel().hide()
	hide()

## 获取窗口的配置文件。
func get_window_config() -> ConfigFile:
	var config := ConfigFile.new()
	const UI := "UI"
	
	config.set_value(UI, "export_path", _get_export_path_line_edit().text)
	config.set_value(UI, "export_name", _get_export_name_line_edit().text)
	config.set_value(UI, "export_include_annotation", _get_include_annotation_check().button_pressed)
	config.set_value(UI, "export_include_empty", _get_include_empty_check().button_pressed)
	return config
## 通过配置文件，配置窗口。
func config_winodw(config : ConfigFile) -> void:
	const UI := "UI"
	
	if not config.has_section(UI):
		return
	
	if config.has_section_key(UI, "export_path"):
		_get_export_path_line_edit().text = config.get_value(UI, "export_path")
	if config.has_section_key(UI, "export_name"):
		_get_export_name_line_edit().text = config.get_value(UI, "export_name")
	_get_include_annotation_check().button_pressed = config.get_value(UI, "export_include_annotation", false)
	_get_include_empty_check().button_pressed = config.get_value(UI, "export_include_empty", false)

# 获取导出路径编辑框。
func _get_export_path_line_edit() -> LineEdit:
	return $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Path
# 获取导出名称编辑框。
func _get_export_name_line_edit() -> LineEdit:
	return $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/Name
# 获取检测标签。
func _get_test_label() -> Label:
	return $MarginContainer/ScrollContainer/VBoxContainer/Test
# 获取保留注释勾选框。
func _get_include_annotation_check() -> CheckBox:
	return $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer3/IncludeAnnotationCheck
# 获取保留空行的勾选框。
func _get_include_empty_check() -> CheckBox:
	return $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer4/IncludeEmptyCheck

# 正在导出 Panel。
func _get_exporting_panel() -> Panel:
	return $Exporting
# 正在导出的标签。
func _get_exporting_label() -> Label:
	return $Exporting/VBoxContainer/Label
# 关闭检测标签。
func _close_test_label() -> void:
	get_ok_button().disabled = false
	var label := _get_test_label()
	label.set_text("")
	label.hide()
# 检测标签发出警告。
func _show_warming(text : String) -> void:
	get_ok_button().disabled = false
	var label := _get_test_label()
	label.set_text(text)
	label.add_theme_color_override(&"font_color", Color.YELLOW)
	label.show()
# 检测标签发出错误。
func _show_error(text : String) -> void:
	get_ok_button().disabled = true
	var label := _get_test_label()
	label.set_text(text)
	label.add_theme_color_override(&"font_color", Color.RED)
	label.show()
# 获取导出目录。
func _get_export_path() -> String:
	return _get_export_path_line_edit().text
# 获取导出名称。
func _get_export_name() -> String:
	return _get_export_name_line_edit().text

## 检测一次路径，有错误返回 [code]true[/code]。
func test_path() -> bool:
	var dir := _get_export_path()
	
	if not (dir.is_absolute_path() or dir.is_relative_path()):
		_show_error("无效文件夹。")
		return true
	
	if not DirAccess.dir_exists_absolute(dir):
		_show_error("文件夹不存在。")
		return true
	
	var nam := _get_export_name() + ".zip"
	
	if not nam.is_valid_filename():
		_show_error("无效文件名。")
		return true
	
	var path := dir.path_join(nam)
	
	if DirAccess.dir_exists_absolute(dir.path_join(nam)):
		_show_warming("存在同名文件夹，将被覆盖。")
		return false
	
	if FileAccess.file_exists(path):
		_show_warming("存在同名文件，将被覆盖。")
		return false
	
	_close_test_label()
	return false

## 导出项目。
func export_project() -> void:
	export_setting = create_setting()
	if export_setting == null:
		return
	var project := ProjectManager.get_current_project()
	
	set_block_signals(true)
	_get_exporting_panel().show()
	
	export_thread = Thread.new()
	export_thread.start(ProjectExport.export.bind(project, export_setting))
	set_process(true)

func _process(_delta: float) -> void:
	if export_thread.is_started() and not export_thread.is_alive():
		export_thread.wait_to_finish()
		_get_exporting_label().text = "导出成功\n只需把文件解压到地图目录behavior_packs并激活行为包即可"
		set_process(false)
		set_block_signals(false)
		return
	
	export_setting.mutex.lock()
	_get_exporting_label().text = "正在导出(%d/%d)\n%s(%d/%d)" %[
		export_setting.main_process, ProjectExportSetting.MainProcess.MAX,
		export_setting.current_process, export_setting.sub_process.x, export_setting.sub_process.y
		]
	export_setting.mutex.unlock()

## 创建设置。
func create_setting() -> ProjectExportSetting:
	var setting := ProjectExportSetting.new()
	if test_path():
		return null
	setting.path = _get_export_path().path_join(_get_export_name())
	setting.include_annotation = _get_include_annotation_check().button_pressed
	setting.include_empty = _get_include_empty_check().button_pressed
	return setting

func _on_path_text_changed(_new_text: String) -> void:
	test_path()

func _on_name_text_changed(_new_text: String) -> void:
	test_path()

func _on_capy_path_pressed() -> void:
	DisplayServer.clipboard_set(export_setting.path)

func _on_open_pressed() -> void:
	var path := export_setting.path + ".zip"
	OS.shell_open(path)
