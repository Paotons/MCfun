extends SplitContainer

## 名称。
@export var split_name : String

## 保存到配置文件。
func save_to_config(config: ConfigFile) -> void:
	config.set_value("Split", split_name, split_offset)

## 从配置文件中加载。
func load_from_config(config: ConfigFile) -> void:
	set_deferred("split_offset", config.get_value("Split", split_name, split_offset))
