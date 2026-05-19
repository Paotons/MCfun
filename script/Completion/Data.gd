class_name CodeCompletionData
extends Resource
## 补全的数据。
##
##

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

## 如果字典是补全字典，返回 [code]true[/code]。
static func is_code_completion_data(dict : Dictionary) -> bool:
	return dict.has_all(["kind", "display_text", "insert_text", "font_color", "icon", "location", "default_value"])

