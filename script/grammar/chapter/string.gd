class_name GrammarStringChapter
extends GrammarChapter
## 字符串类。

## 主数据。
var main_data : PackedStringArray

func _get_type() -> ChapterType:
	return ChapterType.STRING

func _set_data(data : Dictionary) -> void:
	main_data = data[ChapterMeta.DATA]

## 获取所有的物品。
func get_items() -> PackedStringArray:
	return main_data
## 应该有，返回 [code]true[/code]。
func has_item(item : String) -> bool:
	return main_data.has(item)
