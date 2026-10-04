class_name GrammarTranslation
extends Resource
## 语法的翻译。
##
## 用于将语法中的描述部分，翻译成各种语言。

## 语言发生改变。
signal local_changed

## 翻译资源。
var translations : Dictionary[StringName, Translation]

## 语言。
@export var local : String:
	set(value):
		local = value
		_local = StringName(value)
		local_changed.emit()
## 如果为 [code]true[/code]，则开启语言同步。
@export var sync_enabled := true
var _local : StringName

func _init() -> void:
	sync_local()
	TranslationSystem.local_changed.connect.call_deferred(_on_translation_system_local_changed)

## 设置数据。
func set_data(data : Dictionary) -> void:
	for loca : String in data:
		var tl := _create_translation(data[loca])
		tl.locale = loca
		translations[StringName(loca)] = tl

## 返回数据。
func get_data() -> Dictionary:
	var result : Dictionary
	for loca in translations:
		result[loca] = _get_translation_data(translations[loca])
	return result

# 创建翻译器。
static func _create_translation(data : Dictionary) -> Translation:
	var tl := Translation.new()
	for key : String in data:
		var fi := key.find("\u0004")
		
		var msgage := StringName(key) if fi == -1 else StringName(key.substr(fi + 1))
		var context := StringName() if fi == -1 else StringName(key.substr(0, fi))
		var msgstr := StringName(data[key])
		
		tl.add_message(msgage, msgstr, context)
	return tl
# 返回翻译器数据。
static func _get_translation_data(translation : Translation) -> Dictionary:
	var result : Dictionary
	for key in translation.get_message_list():
		var p := key.find("\u0004")
		var untranslated : String
		var context : String
		if p == -1:
			untranslated = key
		else:
			context = key.substr(0, p)
			untranslated = key.substr(p + 1)
		result[key] = translation.get_message(untranslated, context)
	return result

func _on_translation_system_local_changed() -> void:
	if sync_enabled:
		sync_local()

## 同步语言。
func sync_local() -> void:
	local = StringName(TranslationSystem.local)
	local_changed.emit()

## 翻译。
func t(message : StringName, context := &"") -> String:
	var m := String(translations[_local].get_message(message, context)) if translations.has(_local) else String(message)
	return String(message) if m.is_empty() else m
## 批量翻译。
func ts(messages : Array[StringName], contexts : Array[StringName] = []) -> PackedStringArray:
	contexts.resize(messages.size())
	var result : PackedStringArray
	result.resize(messages.size())
	for i in messages.size():
		result[i] = t(messages[i], contexts[i])
	return result
## 返回加载的语言。
func get_loaded_local() -> PackedStringArray:
	var res : PackedStringArray
	for loca : StringName in translations.keys():
		res.append(String(loca))
	return res
## 如果有加载的语言，返回 [code]true[/code]。
func has_loaded_local(loca : String) -> bool:
	return translations.has(StringName(loca))
