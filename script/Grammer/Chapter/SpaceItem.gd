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

## 解析。
static func compile(from : Dictionary, to : Dictionary) -> bool:
	if _compile_data(from, to): return true
	return true

# 解析数据。
static func _compile_data(from : Dictionary, to : Dictionary) -> bool:
	if not from.has("data"):
		push_error("Not has meta \"data\".")
		return true
	var data = from["data"]
	if data is Dictionary:
		var to_data : Dictionary
		if _compile_space(data, to_data): return true
		to[ChapterMeta.DATA] = to_data
		return false
	else:
		push_error("Meta \"data\" should be dictionary, but is \"%s\"." % [type_string(typeof(data))])
		return true

# 解析命名空间。
static func _compile_space(from : Dictionary, to : Dictionary) -> bool:
	for space in from:
		if not space is String:
			push_error("Space should be string, but is \"%s\"." % [type_string(typeof(space))])
			return true
		var item = from[space]
		if not item is Array:
			push_error("Space \"%s\" data should be array, but is \"%s\"." % [space, type_string(typeof(item))])
			return true
		var to_item : Array
		if _compile_item(item, to_item): return true
		to[space] = to_item
	return false

# 解析物品。
static func _compile_item(from : Array, to : Array) -> bool:
	for item in from:
		if not item is String:
			push_error("Item should be string, but is \"%s\"." % [type_string(typeof(item))])
			return true
	to.append_array(from)
	return false

