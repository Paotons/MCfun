class_name SettingWindow
extends Window
## 设置窗口。

@onready var _save_reopen_node := $VBoxContainer/SaveReopen as MarginContainer

func _init() -> void:
	visible = false

## 设置保存重启状态。
func set_save_reopen_visible(enabled : bool) -> void:
	_save_reopen_node.visible = enabled

## 保存重启。
func save_reopen() -> void:
	pass

