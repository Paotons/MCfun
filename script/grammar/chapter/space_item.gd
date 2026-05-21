class_name GrammarSpaceItemChapter
extends GrammarChapter
## 空间物品类。
##
## 提供空间物品访问的。

# 空间下的物品的物品。
const _SPACE_ITEM_ITEMS := 0
# 空间下的物品的显示。
const _SPACE_ITEM_DIZPLAYS := 1

# 主数据。
var main_data : Dictionary
# 空间顺序。
var _queue_spaces : PackedStringArray

func _get_type() -> ChapterType:
	return ChapterType.SPACEITEM

func _set_data(data : Dictionary) -> void:
	main_data = data[ChapterMeta.DATA]
	_queue_spaces = PackedStringArray(main_data.keys())

## 返回空间数量。
func get_space_count() -> int:
	return _queue_spaces.size()
## 返回所有空间。
func get_spaces() -> PackedStringArray:
	return _queue_spaces
## 如果有空间，返回 [code]true[/code]。
func has_space(space : String) -> bool:
	return _queue_spaces.has(space)
## 返回指定空间中所有物品。
func get_space_items(space := "minecraft") -> PackedStringArray:
	if not has_space(space):
		return PackedStringArray()
	return _get_space_items(space)
## 返回指定空间中物品的数量。
func get_space_items_count(space := "minecraft") -> int:
	if not has_space(space):
		return 0
	return _get_space_items_count(space)
## 返回指定空间中的显示。
func get_space_displays(space := "minecraft") -> PackedStringArray:
	if not has_space(space):
		return PackedStringArray()
	return _get_space_displays(space)
## 如果指定空间中有物品，返回 [code]true[/code]。
func has_space_item(space : String, item : String) -> bool:
	if not has_space(space):
		return false
	return _is_space_has_items(space, item)
## 返回所有物品。
func get_items(include_space := true) -> PackedStringArray:
	var res : PackedStringArray
	if include_space:
		for space in _queue_spaces:
			for item in _get_space_items(space):
				res.append(space + ":" + item)
	else:
		for space in _queue_spaces:
			res.append_array(_get_space_items(space))
	return res
## 返回显示。
func get_displays() -> PackedStringArray:
	var res : PackedStringArray
	for space in _queue_spaces:
		var displays : PackedStringArray = _get_space_displays(space)
		if displays.is_empty() and _get_space_items_count(space) != 0:
			displays.resize(_get_space_items_count(space))
		res.append_array(displays)
	return res
## 如果有物品，返回 [code]true[/code]。
func has_item(item : String) -> bool:
	var colon := item.find(item)
	if colon == -1:
		for space in _queue_spaces:
			if has_space_item(space, item): return true
		return false
	else:
		return has_space_item(item.substr(0, colon), item.substr(colon + 1))

func _is_space_has_items(space : String, items : String) -> bool:
	return (main_data[space][_SPACE_ITEM_ITEMS] as Array).has(items)
func _get_space_items_count(space : String) -> int:
	return (main_data[space][_SPACE_ITEM_ITEMS] as Array).size()
func _get_space_items(space : String) -> PackedStringArray:
	return main_data[space][_SPACE_ITEM_ITEMS]
func _get_space_displays(space : String) -> PackedStringArray:
	return main_data[space][_SPACE_ITEM_DIZPLAYS]
