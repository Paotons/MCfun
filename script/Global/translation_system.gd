extends Node
## 全局单例，TranslationServer。

# 各个语言的名称。
const _LOCAL_NAMES := preload("res://resource/tr/local_names.json").data

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

## 翻译。与[method Node.tr]相比，该函数允许在任何情况下调用。
func t(message : StringName, context := &"") -> StringName:
	return TranslationServer.translate(message, context)

## 设置语言。
func set_lanauage(value : String) -> void:
	local = value
	TranslationServer.set_locale(local)
	FileSystem.config.set_value(_CONFIG_SELECTOR, _CONFIG_SELECTOR_KEY, value)
	local_changed.emit()
	FileSystem.config.save(FileSystem.config_path)
## 返回指定语言的名称，失败返回其本身。
func get_local_name(loca : String) -> String:
	return loca if not _LOCAL_NAMES.has(loca) else (_LOCAL_NAMES[loca] as Dictionary).get("name", loca)
## 返回指定语言在英语下的名称，失败返回其本身。
func get_local_english_name(loca : String) -> String:
	return loca if not _LOCAL_NAMES.has(loca) else (_LOCAL_NAMES[loca] as Dictionary).get("english", loca)
