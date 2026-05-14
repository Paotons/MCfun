class_name GrammerSpaceItemChapter
extends GrammerChapter
## 空间物品类。
##
## 提供空间物品访问的。

# 主数据。
var main_data : Dictionary

func _get_type() -> ChapterType:
	return ChapterType.SPACEITEM

func _set_data(data : Dictionary) -> void:
	main_data = data[ChapterMeta.DATA]

## 获取空间。
func get_spaces() -> PackedStringArray:
	return main_data.keys()
## 如果有空间，返回 [code]true[/code]。
func has_space(space : String) -> bool:
	return main_data.has(space)
## 获取物品。
func get_space_items(space := "minecraft") -> PackedStringArray:
	var data := main_data.get(space, {}) as Array
	return data
## 如果空间有物品，返回 [code]true[/code]。
func has_space_item(space : String, item : String) -> bool:
	if not has_space(space): return false
	var dat := main_data[space] as Array
	return dat.has(item)
## 获取物品。
func get_items(include_space := true) -> PackedStringArray:
	var res : PackedStringArray
	if include_space:
		for space : String in main_data:
			for item : String in main_data[space]:
				res.append(space + ":" + item)
	else:
		for space : String in main_data:
			for item : String in main_data[space]:
				res.append(item)
	return res
## 如果有物品，返回 [code]true[/code]。
func has_item(item : String) -> bool:
	var colon := item.find(item)
	if colon == -1:
		for space : String in main_data:
			if has_space_item(space, item): return true
		return false
	else:
		return has_space_item(item.substr(0, colon), item.substr(colon + 1))
