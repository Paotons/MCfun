class_name GrammerStringChapter
extends GrammerChapter
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

## 解析。
static func compile(from : Dictionary, to : Dictionary) -> bool:
	if _compile_data(from, to): return true
	return false

# 解析数据。
static func _compile_data(from : Dictionary, to : Dictionary) -> bool:
	if not from.has("data"):
		push_error("Not has meta \"data\".")
		return true
	var data = from["data"]
	if data is Array:
		var to_data : Array
		if _compile_item(data, to_data): return true
		to[ChapterMeta.DATA] = to_data
		return false
	else:
		push_error("Meta \"data\" should be dictionary, but is \"%s\"." % [type_string(typeof(data))])
	return false

# 解析物品。
static func _compile_item(from : Array, to : Array) -> bool:
	var i := 0
	to.resize(from.size())
	for item in from:
		if not item is String:
			push_error("Item should be string, but is \"%s\"." % [type_string(typeof(item))])
			return true
		to[i] = item
		i += 1
	return false
