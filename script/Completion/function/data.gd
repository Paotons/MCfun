class_name FunctionCompletionData
extends CodeCompletionData
## 函数补全数据。

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

func set_inserted_update(idx := -1, enabled := true) -> void:
	idx = insert_texts.size() + idx if idx < 0 else idx
	if values.size() <= idx:
		values.resize(idx + 1)
	var value := values[idx]
	if value == null:
		value = FunctionCompletionDataValue.new()
		values[idx] = value
	value.inserted_update = enabled
func fill_inserted_update(enabled : bool) -> void:
	for value in values:
		value.inserted_update = enabled
	var size_ := values.size()
	values.resize(insert_texts.size())
	for i in range(size_, insert_texts.size()):
		var value := FunctionCompletionDataValue.new()
		value.inserted_update = enabled
		values[i] = value

## 设置插入模式。
func set_insert_mode(idx := -1, mode := InsertMode.NORMAL) -> void:
	var value : FunctionCompletionDataValue = get_value(idx)
	if value == null:
		value = FunctionCompletionDataValue.new()
		values[idx] = value
	value.insert_mode = mode
## 填充插入模式。
func fill_insert_mode(mode := InsertMode.NORMAL) -> void:
	for value in values:
		value.insert_mode = mode
	
	var size_ := values.size()
	values.resize(insert_texts.size())
	for i in range(size_, insert_texts.size()):
		var value := FunctionCompletionDataValue.new()
		value.insert_mode = mode
		values[i] = value
## 获取指定序列的插入模式。
func get_insert_mode(idx : int) -> InsertMode:
	var value := values[idx]
	return value.insert_mode if value != null else InsertMode.NORMAL
## 添加指定序列的额外权重。
func add_extra_weight(idx := -1, weight := 128) -> void:
	var value : FunctionCompletionDataValue = get_value(idx)
	if value == null:
		value = FunctionCompletionDataValue.new()
		values[idx] = value
	value.extra_weight += weight
## 获取指定序列的额外权重。
func get_extra_weight(idx : int) -> int:
	if idx < 0 or idx >= values.size():
		return 0
	var value : FunctionCompletionDataValue = values[idx]
	return value.extra_weight

#region 获取权重
## 获取权重。
static func get_weight(text : String, column : int, data : Dictionary, hint_word := false) -> int:
	var chache : Dictionary[_WeightChache, String]
	var insert : String = data.insert_text
	var value : FunctionCompletionDataValue = data.default_value
	var insert_mode : InsertMode = value.insert_mode if value else InsertMode.NORMAL
	
	var weight := value.extra_weight
	match insert_mode:
		InsertMode.NORMAL: weight += _get_weight_normal(text, column, insert, chache)
		InsertMode.WORLD: weight += _get_weight_world(text, column, insert, chache)
		InsertMode.SPACEITEM: weight += _get_weight_spaceitem(text, column, insert, chache)
		InsertMode.QUOTATION: weight += _get_weight_quotation(text, column, insert, chache)
		InsertMode.POINT_PATH: weight += _get_weight_point_path(text, column, insert, chache)
		_: weight += _get_weight_normal(text, column, insert, chache)
	return maxi(weight, _get_weight_world(text, column, data.display_text, chache)) if hint_word else weight

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

# 强调补全额外权重。
const _HIGHLIGHT_EXTRA_WEIGHT := 768 # 3 * 256，等效两次连续加权

## 创建一个补全括号的数据。
static func create_backet_data(type : GrammarValue.Type) -> FunctionCompletionData:
	assert(GrammarValue.is_type_backet(type), "Not is backet type.")
	var res := FunctionCompletionData.new()
	
	match type:
		GrammarValue.Type.QUOTATION : res.insert_texts = ["\"\""]
		GrammarValue.Type.ARRAY : res.insert_texts = ["[]"]
		GrammarValue.Type.DICTIONARY : res.insert_texts = ["{}"]
	
	var value := FunctionCompletionDataValue.new()
	value.inserted_update = true
	value.extra_weight = _HIGHLIGHT_EXTRA_WEIGHT
	value.inserted_column_offset = -1
	res.values = [value]
	return res
## 创建一个符号数据。
static func create_flag_data(flag : String, updated := true, column_offset := 0) -> FunctionCompletionData:
	var res := FunctionCompletionData.new()
	res.insert_texts = [flag]
	
	var value := FunctionCompletionDataValue.new()
	value.inserted_update = updated
	value.extra_weight = _HIGHLIGHT_EXTRA_WEIGHT
	value.inserted_column_offset = column_offset
	res.values = [value]
	return res
