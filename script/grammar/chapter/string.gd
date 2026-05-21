class_name GrammarStringChapter
extends GrammarChapter
## 字符串类。

enum _MetaType {
	# 物品。
	ITEMS,
	# 物品的显示。
	DISPLAYS,
}

## 主数据。
var main_data : Dictionary

func _get_type() -> ChapterType:
	return ChapterType.STRING

func _set_data(data : Dictionary) -> void:
	main_data = data[ChapterMeta.DATA]

## 获取所有的物品。
func get_items() -> PackedStringArray:
	return main_data[_MetaType.ITEMS]
## 获取物品的显示。
func get_displays() -> PackedStringArray:
	return main_data[_MetaType.DISPLAYS]

## 如果有指定物体，返回 [code]true[/code]。
func has_item(item : String) -> bool:
	return get_items().has(item)
