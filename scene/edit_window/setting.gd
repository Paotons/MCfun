class_name SettingWindow
extends Window
## 设置窗口。

## 重新加载项目。
signal reload_scene

@onready var _save_reopen_node := $VBoxContainer/SaveReopen as MarginContainer

func _init() -> void:
	visible = false

## 设置保存重启状态。
func set_save_reopen_visible(enabled : bool) -> void:
	_save_reopen_node.visible = enabled

func _on_button_pressed() -> void:
	reload_scene.emit()
