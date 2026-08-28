extends Node
## 全局单例，TranslationServer。

func _ready() -> void:
	var config := ConfigFile.new()
	if FileAccess.file_exists(FileSystem.config_path):
		config.load(FileSystem.config_path)
	TranslationServer.set_locale(config.get_value("UINormal", "translation", OS.get_locale()))
