class_name EditSettingConfigSpinBox
extends SpinBox
## 编辑器设置中配置文件勾选框。

## 更新编辑器状态。
signal update_edit(number : float)

## 配置文件选项。
@export var config_selector : String
## 配置文件键。
@export var config_key : String
## 默认值。
@export var default_value := 0.0
## 如果为 [code]true[/code]，则会保存为整数。
@export var saved_int := false

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	visibility_changed.connect(_on_visibility_changed)

## 虚函数，更新编辑器。
@warning_ignore("unused_parameter")
func _update_edit(number : float) -> void:
	return
## 虚函数，返回值。
func _get_config_value(config : ConfigFile) -> float:
	return floori(config.get_value(config_selector, config_key, default_value)) if saved_int else config.get_value(config_selector, config_key, default_value)
## 虚函数，设置值。
func _set_config_value(config : ConfigFile, number : float) -> void:
	@warning_ignore("incompatible_ternary")
	config.set_value(config_selector, config_key, floori(number) if saved_int else number)

@warning_ignore("shadowed_variable_base_class")
func _on_value_changed(value : float) -> void:
	var config := ConfigFile.new()
	if FileAccess.file_exists(FileSystem.config_path):
		config.load(FileSystem.config_path)
	_set_config_value(config, value)
	config.save(FileSystem.config_path)
	FileSystem.reload_config()
	
	if EditBaseControl.is_editing():
		update()

## 更新编辑器。
func update() -> void:
	_update_edit(value)
	update_edit.emit(value)

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		return
	var config := ConfigFile.new()
	if FileAccess.file_exists(FileSystem.config_path):
		config.load(FileSystem.config_path)
	set_block_signals(true)
	value = _get_config_value(config)
	set_block_signals(false)
