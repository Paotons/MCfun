extends OptionButton

const TRANSLATIONS : PackedStringArray = ["zh", "en"]

func _ready() -> void:
	TranslationSystem.local_changed.connect(_on_translation_system_local_changed)
	visibility_changed.connect(_on_visibility_changed)
	item_selected.connect(_on_item_selected)

## 更新一下。
func update_local() -> void:
	select(get_translation_index(TranslationSystem.local))

## 返回指定翻译的序列。
func get_translation_index(nam : String) -> int:
	var i := TRANSLATIONS.find(nam)
	return 0 if i == -1 else i

func _on_translation_system_local_changed() -> void:
	update_local()

func _on_visibility_changed() -> void:
	if visible:
		update_local()

func _on_item_selected(index: int) -> void:
	var trans := TRANSLATIONS[index]
	TranslationSystem.local = trans
