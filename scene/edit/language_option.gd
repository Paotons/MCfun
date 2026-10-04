extends OptionButton

## 用到的语言。
var locals : PackedStringArray

func _ready() -> void:
	update_list()
	
	TranslationSystem.local_changed.connect(_on_translation_system_local_changed)
	visibility_changed.connect(_on_visibility_changed)
	item_selected.connect(_on_item_selected)

## 更新一下翻译列表。
func update_list() -> void:
	clear()
	var ls := TranslationServer.get_loaded_locales()
	for l in ls:
		add_item("%s (%s)" % [TranslationSystem.get_local_english_name(l), TranslationSystem.get_local_name(l)])
	locals = ls

## 更新一下选中的翻译。
func update_local() -> void:
	select(get_translation_index(TranslationSystem.local))

## 返回指定翻译的序列。
func get_translation_index(nam : String) -> int:
	var i := locals.find(nam)
	return 0 if i == -1 else i

func _on_translation_system_local_changed() -> void:
	update_local()

func _on_visibility_changed() -> void:
	if visible:
		update_local()

func _on_item_selected(index: int) -> void:
	var trans := locals[index]
	TranslationSystem.local = trans
