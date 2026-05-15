class_name ProjectListContainer
extends MarginContainer
## 项目列表的容器。

## 被点击时发出。
signal pressed

@onready var _project_name_label := $MarginContainer/VBoxContainer/Label as Label
@onready var _project_information_label := $MarginContainer/VBoxContainer/Label2 as Label

## 项目选键。
const PROJECT_SELECT_NAME := "Project"
# 配置文件项目的键。
const CONFIG_PROJECT_KEYS : PackedStringArray = ["name", "nearest_time", "path"]

## 项目名称。
var project_name : String

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			pressed.emit()

## 设置选中状态。
func set_select_mode(enabled : bool) -> void:
	_project_name_label.add_theme_color_override("font_color", Color(0.0, 0.694, 0.831, 1.0) if enabled else Color.WHITE)

# 如果是项目配置文件的键，返回 真。
func _is_valid_project_keys(keys : PackedStringArray) -> bool:
	var dict : Dictionary[String, bool]
	for key in keys:
		dict[key] = false
	return dict.has_all(CONFIG_PROJECT_KEYS)

## 通过配置文件进行加载。
func load_config(config : ConfigFile) -> void:
	if config == null:
		set_error_project()
		return
	if not config.has_section(PROJECT_SELECT_NAME):
		set_error_project()
		return
	
	var project_keys := config.get_section_keys(PROJECT_SELECT_NAME)
	if not _is_valid_project_keys(project_keys):
		set_error_project()
		return
	
	set_project_name(config.get_value(PROJECT_SELECT_NAME, "name"))
	set_project_nearest_time(config.get_value(PROJECT_SELECT_NAME, "nearest_time"))
	set_project_path(config.get_value(PROJECT_SELECT_NAME, "path"))

## 设置项目目录。
func set_project_path(path : String) -> void:
	path = path.replace(" ", "_")
	var text := _project_information_label.text
	var result := text.split(" ")
	result[0] = path
	_project_information_label.text = " ".join(result)
## 设置项目最近时间。
func set_project_nearest_time(time : String) -> void:
	var text := _project_information_label.text
	var result := text.split(" ")
	result[1] = time
	_project_information_label.text = " ".join(result)

@warning_ignore("shadowed_variable_base_class")
## 设置项目名称。
func set_project_name(name : String) -> void:
	project_name = name
	_project_name_label.set_text(name)

## 设置成错误项目。
func set_error_project() -> void:
	_project_name_label.add_theme_color_override("font_color", Color("c00"))
	_project_name_label.set_text("项目丢失")
	_project_information_label.hide()
