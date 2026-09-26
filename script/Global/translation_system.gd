extends Node
## 全局单例，TranslationServer。

## 语言发生改变。
signal local_changed()

const _CONFIG_SELECTOR := "UINormal"
const _CONFIG_SELECTOR_KEY := "translation"

## 翻译的语言。
var local : String:
	set = set_lanauage

func _ready() -> void:
	local = FileSystem.config.get_value(_CONFIG_SELECTOR, _CONFIG_SELECTOR_KEY, OS.get_locale())
	TranslationServer.set_locale(local)

## 设置语言。
func set_lanauage(value : String) -> void:
	local = value
	TranslationServer.set_locale(local)
	FileSystem.config.set_value(_CONFIG_SELECTOR, _CONFIG_SELECTOR_KEY, value)
	local_changed.emit()
	FileSystem.config.save(FileSystem.config_path)
