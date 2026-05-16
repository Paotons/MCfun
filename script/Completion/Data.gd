class_name CodeCompletionData
extends Resource
## 补全的数据。
##
##

## 补全模式。
enum InsertMode {
	## 默认补全，直接加入。
	NORMAL,
	## 单词补全，替换前方单词。
	WORLD,
	## 字符串补全，替换前方字符串。
	STRING,
	
	#region 针对性的。
	## 空间物品。
	SPACEITEM,
	## 目标选择器。
	SELECTOR,
	## 引号模式。
	QUOTATION,
	## 点号路径模式。
	POINT_PATH,
}

# 权重缓存数据。
enum _WeightChache {
	STRING, # 字符串
	WORLD, # 单词
	SPACEITEM_SPACE, # 空间物品的空间名
	SPACEITEM_ITEM, # 空间物品的物品名
	QUOTATION, # 引号
	POINT_PATH, # 点号路径
}

## 提示。
var hint_string : String

## 类别。
var kinds : Array[CodeEdit.CodeCompletionKind]
## 显示的文本。
var display_texts : PackedStringArray
## 插入的文本。
var insert_texts : PackedStringArray
## 文本颜色。
var text_colors : PackedColorArray
## 文本图标。
var icons : Array[Texture2D]
## 变量。
var values : Array[CodeCompletionDataValue]
## 位置。
var locations : PackedInt64Array

## 设置插入模式。
func set_insert_mode(idx := -1, mode := InsertMode.NORMAL) -> void:
	idx = insert_texts.size() + idx if idx < 0 else idx
	if values.size() <= idx:
		values.resize(idx + 1)
	var value := values[idx]
	if value == null:
		value = CodeCompletionDataValue.new()
		values[idx] = value
	value.insert_mode = mode
## 获取插入模式。
func get_insert_mode(idx : int) -> InsertMode:
	var value := values[idx]
	return value.insert_mode if value != null else InsertMode.NORMAL
## 填充插入模式。
func fill_insert_mode(mode := InsertMode.NORMAL) -> void:
	for value in values:
		value.insert_mode = mode
	var size_ := values.size()
	values.resize(insert_texts.size())
	for i in range(size_, insert_texts.size()):
		var value := CodeCompletionDataValue.new()
		value.insert_mode = mode
		values[i] = value

## 设置插入后更新状态。
func set_inserted_update(idx := -1, enabled := true) -> void:
	idx = insert_texts.size() + idx if idx < 0 else idx
	if values.size() <= idx:
		values.resize(idx + 1)
	var value := values[idx]
	if value == null:
		value = CodeCompletionDataValue.new()
		values[idx] = value
	value.inserted_update = enabled
## 如果是插入后立即更新，返回 [code]true[/code]。
func is_inserted_update(idx : int) -> bool:
	var value := values[idx]
	return value.inserted_update if value != null else false
## 填充插入更新方式。
func fill_inserted_update(enabled : bool) -> void:
	for value in values:
		value.inserted_update = enabled
	var size_ := values.size()
	values.resize(insert_texts.size())
	for i in range(size_, insert_texts.size()):
		var value := CodeCompletionDataValue.new()
		value.inserted_update = enabled
		values[i] = value

#region 获取权重
## 获取权重。
static func get_weight(text : String, column : int, data : Dictionary) -> int:
	var chache : Dictionary[_WeightChache, String]
	var insert : String = data.insert_text
	var value : CodeCompletionDataValue = data.default_value
	var insert_mode := value.insert_mode if value else InsertMode.NORMAL
	match insert_mode:
		InsertMode.NORMAL: return _get_weight_normal(text, column, insert, chache)
		InsertMode.WORLD: return _get_weight_world(text, column, insert, chache)
		InsertMode.SPACEITEM: return _get_weight_spaceitem(text, column, insert, chache)
		InsertMode.QUOTATION: return _get_weight_quotation(text, column, insert, chache)
		InsertMode.POINT_PATH: return _get_weight_point_path(text, column, insert, chache)
		_: return _get_weight_normal(text, column, insert, chache)

# 获取权重，普通。
static func _get_weight_normal(text : String, column : int, insert : String, chache : Dictionary[_WeightChache, String]) -> int:
	if not chache.has(_WeightChache.STRING):
		chache[_WeightChache.STRING] = StrT.get_string(text, column - 1)
	return StrT.get_fuzzy_weight(insert, chache[_WeightChache.STRING])
# 获取权重，单词。
static func _get_weight_world(text : String, column : int, insert : String, chache : Dictionary[_WeightChache, String]) -> int:
	if not chache.has(_WeightChache.WORLD):
		chache[_WeightChache.WORLD] = StrT.get_letter(text, column - 1)
	return StrT.get_fuzzy_weight(insert, chache[_WeightChache.WORLD])

# 获取权重，物品空间。
static func _get_weight_spaceitem(text : String, column : int, insert : String, chache : Dictionary[_WeightChache, String]) -> int:
	if not chache.has_all([_WeightChache.SPACEITEM_SPACE, _WeightChache.SPACEITEM_ITEM]):
		var strart := StrT.rfind_unletter(text, column - 1)
		var end := StrT.find_unletter(text, column)
		var colon := strart if text[strart] == ":" else end if text[end] == ":" else -1
		chache[_WeightChache.SPACEITEM_SPACE] = StrT.get_letter(text, colon - 1) if colon != -1 else ""
		chache[_WeightChache.SPACEITEM_ITEM] = StrT.get_letter(text, colon + 1) if colon != -1 else StrT.get_letter(text, column - 1)
	return StrT.get_fuzzy_weight(insert, chache[_WeightChache.SPACEITEM_SPACE]) + StrT.get_fuzzy_weight(insert, chache[_WeightChache.SPACEITEM_ITEM])
# 获取权重，引号数据。
static func _get_weight_quotation(text : String, column : int, insert : String, chache : Dictionary[_WeightChache, String]) -> int:
	if not StrT.is_quotation(insert):
		return _get_weight_normal(text, column, insert, chache)
	if not chache.has(_WeightChache.QUOTATION):
		var quo := StrT.get_quotation(text, column - 2, false)
		chache[_WeightChache.QUOTATION] = StrT.get_letter(text, column - 1) if quo.is_empty() else quo
	insert = insert.substr(1, insert.length() - 2)
	return StrT.get_fuzzy_weight(insert, chache[_WeightChache.QUOTATION])
# 获取权重，点号路径。
static func _get_weight_point_path(text : String, column : int, insert : String, chache : Dictionary[_WeightChache, String]) -> int:
	if not chache.has(_WeightChache.POINT_PATH):
		chache[_WeightChache.POINT_PATH] = PointPathElement.find_point_path_string(text, column - 1).replace(".", "")
	return StrT.get_fuzzy_weight(insert, chache[_WeightChache.POINT_PATH])
#endregion

## 创建一个补全括号的数据。
static func create_backet_data(type : GrammarValue.Type) -> CodeCompletionData:
	assert(GrammarValue.is_type_backet(type), "Not is backet type.")
	var res := CodeCompletionData.new()
	
	match type:
		GrammarValue.Type.QUOTATION : res.insert_texts = ["\"\""]
		GrammarValue.Type.ARRAY : res.insert_texts = ["[]"]
		GrammarValue.Type.DICTIONARY : res.insert_texts = ["{}"]
	
	var value := CodeCompletionDataValue.new()
	value.inserted_update = true
	value.inserted_column_offset = -1
	res.values = [value]
	return res
## 获取大小。
func size() -> int:
	return insert_texts.size()
## 如果已经补充过了，返回 [code]true[/code]。
func is_suppled() -> bool:
	var size_ := size()
	return kinds.size() == size_ and display_texts.size() == size_ and text_colors.size() == size_ and icons.size() == size_ and values.size() == size_ and locations.size() == size_
## 补充。
func supple() -> void:
	var size_ := size()
	var arr : Array
	
	arr.resize(size_ - kinds.size())
	arr.fill(CodeEdit.CodeCompletionKind.KIND_MEMBER)
	kinds.append_array(arr)
	
	display_texts.append_array(insert_texts.slice(display_texts.size(), size_))
	
	arr.resize(size_ - text_colors.size())
	arr.fill(Color.WHITE)
	text_colors.append_array(arr)
	
	arr.resize(size_ - icons.size())
	arr.fill(null)
	icons.append_array(arr)
	
	arr.resize(size_ - values.size())
	arr.fill(null)
	values.append_array(arr)
	
	arr.resize(size_ - locations.size())
	arr.fill(1024)
	locations.append_array(arr)
## 对已经 [method supple] 的数据加入新数据。
func add_data(data : CodeCompletionData) -> void:
	if data == null: return
	if not is_suppled():
		push_error("Data is not suppled")
		supple()
	if not data.hint_string.is_empty():
		hint_string += data.hint_string if hint_string.is_empty() else "/" + data.hint_string
	kinds.append_array(data.kinds)
	display_texts.append_array(data.display_texts)
	insert_texts.append_array(data.insert_texts)
	text_colors.append_array(data.text_colors)
	icons.append_array(data.icons)
	values.append_array(data.values)
	locations.append_array(data.locations)

#region 插入
## 获取插入的起始位置。
static func get_insert_start(text : String, column : int, data : Dictionary) -> int:
	assert(is_code_completion_data(data), "Unvalid data.")
	var value : CodeCompletionDataValue = data.default_value
	var insert_mode : InsertMode = InsertMode.NORMAL if value == null else value.insert_mode
	match insert_mode:
		InsertMode.NORMAL: return column
		InsertMode.WORLD: return _get_insert_start_world(text, column)
		
		InsertMode.SPACEITEM: return _get_insert_start_spaceitem(text, column)
		InsertMode.SELECTOR: return _get_insert_start_selector(text, column)
		InsertMode.QUOTATION: return _get_insert_start_quotation(text, column)
		InsertMode.POINT_PATH: return _get_insert_start_point_path(text, column)
		_: return column
## 获取插入的终点位置。
static func get_insert_end(text : String, column : int, data : Dictionary) -> int:
	assert(is_code_completion_data(data), "Unvalid data.")
	var value : CodeCompletionDataValue = data.default_value
	var insert_mode : InsertMode = InsertMode.NORMAL if value == null else value.insert_mode
	match insert_mode:
		InsertMode.NORMAL: return column
		InsertMode.WORLD: return _get_insert_end_world(text, column)
		
		InsertMode.SPACEITEM: return _get_insert_end_spaceitem(text, column)
		InsertMode.SELECTOR: return _get_insert_end_selector(text, column)
		InsertMode.QUOTATION: return _get_insert_end_quotation(text, column)
		InsertMode.POINT_PATH: return _get_insert_end_point_path(text, column)
		_: return column

# 获取单词补全的开头。
static func _get_insert_start_world(text : String, column : int) -> int:
	var a := StrT.rfind_unletter(text, column - 1)
	return 0 if a == -1 else a + 1
# 获取单词补全的结尾。
static func _get_insert_end_world(text : String, column : int) -> int:
	var a := StrT.find_unletter(text, column)
	return column if a == -1 else a

# 获取单词补全的开头。
static func _get_insert_start_spaceitem(text : String, column : int) -> int:
	var a := StrT.rfind_unletter(text, column - 1)
	if text[a] == ":":
		a = StrT.rfind_unletter(text, a - 1)
	return 0 if a == -1 else a + 1
# 获取单词补全的结尾。
static func _get_insert_end_spaceitem(text : String, column : int) -> int:
	var a := StrT.find_unletter(text, column)
	if a == -1: return text.length()
	if text[a] == ":":
		a = StrT.find_unletter(text, a + 1)
	return text.length() if a == -1 else a

# 获取目标选择器补全的开头。
static func _get_insert_start_selector(text : String, column : int) -> int:
	while column > 0:
		column -= 1
		var chr_ord := ord(text[column])
		if not StrT.is_letter_char_ord(chr_ord):
			return column if chr_ord == 64 else column + 1 # 64 -> @
	return 0
# 获取目标选择器补全的结尾。
static func _get_insert_end_selector(text : String, column : int) -> int:
	return _get_insert_end_world(text, column)

# 获取引号补全的开头。
static func _get_insert_start_quotation(text : String, column : int) -> int:
	var head_char := text[column - 1]
	var a := -1
	if head_char == "\"": a = StrT.rfind_quotation(text, column - 2)
	elif StrT.is_letter_char_ord(ord(head_char)): a = StrT.rfind_quotation(text, column - 1)
	else: a = column
	return column if a == -1 else a
# 获取引号补全的结尾。
static func _get_insert_end_quotation(text : String, column : int) -> int:
	var a := StrT.find_quotation(text, column)
	return _get_insert_end_world(text, column) if a == -1 else a + 1

# 获取点号路径的开头。
static func _get_insert_start_point_path(text : String, column : int) -> int:
	var res := PointPathElement.rfind_point_path(text, column - 1)
	return _get_insert_end_world(text, column) if res == -1 else res
# 获取引号补全的结尾。
static func _get_insert_end_point_path(text : String, column : int) -> int:
	var res := PointPathElement.find_point_path(text, column)
	return _get_insert_end_world(text, column) if res == -1 else res
#endregion

## 如果字典是补全字典，返回 [code]true[/code]。
static func is_code_completion_data(dict : Dictionary) -> bool:
	return dict.has_all(["kind", "display_text", "insert_text", "font_color", "icon", "location", "default_value"])

