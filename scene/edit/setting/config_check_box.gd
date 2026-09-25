class_name EditSettingConfigCheckBox
extends CheckBox
## 编辑器设置中配置文件勾选框。

## 更新编辑器状态。
signal update_edit(enabled : bool)

## 配置文件选项。
@export var config_selector : String
## 配置文件键。
@export var config_key : String
## 默认值。
@export var default_value : bool

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

## 虚函数，更新编辑器。
@warning_ignore("unused_parameter")
func _update_edit(enabled : bool) -> void:
	return
## 虚函数，返回值。
func _get_config_value(config : ConfigFile) -> bool:
	return config.get_value(config_selector, config_key, default_value)
## 虚函数，设置值。
func _set_config_value(config : ConfigFile, value : bool) -> void:
	config.set_value(config_selector, config_key, value)

func _pressed() -> void:
	var config := ConfigFile.new()
	if FileAccess.file_exists(FileSystem.config_path):
		config.load(FileSystem.config_path)
	_set_config_value(config, button_pressed)
	config.save(FileSystem.config_path)
	FileSystem.reload_config()
	
	if EditBaseControl.is_editing():
		_update_edit(button_pressed)
		update_edit.emit(button_pressed)

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		return
	var config := ConfigFile.new()
	if FileAccess.file_exists(FileSystem.config_path):
		config.load(FileSystem.config_path)
	set_block_signals(true)
	button_pressed = _get_config_value(config)
	set_block_signals(false)
