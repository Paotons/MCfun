class_name CustomCodeEdit
extends CodeEdit
## 自定义编辑器。
##
## 加入了行 ID，双击输入。

## 新的一行被加入。
signal line_added(line : int, line_id : int)
## 一行被移除。
signal line_removed(line : int, line_id : int)
## 行 ID 被重置时发出。
signal line_id_reseted(old_ids : PackedInt32Array, new_ids : PackedInt32Array)

## 退格。
const UNICODE_BACKSPACE := 8
## 缩进。
const UNICODE_TAB := 9
## 换行。
const UNICODE_ENTER := 10


#region 输入
@export_group("input")
## 双击输入映射表，双击键值会替换为值，直接更改不会起作用，需要 [method set_double_input_map]。
@export var double_input_map : Dictionary[String, String]
## 如果为 [code]true[/code]，双击映射将被禁用。
@export var double_input_disabled := false
## 双击事件最长可识别时间差，单位(ms)。
@export var double_input_interval_time := 256
# 解析过的双击事件映射表, int -> String。
var _double_input_map_compiled : Dictionary[int, String] = {}
## 最近一次光标输入时间。
var _nearest_input_time : Dictionary[int, int]
## 最近一次光标输入字符编码。
var _nearest_input_unicode : Dictionary[int, int]
## 最近一次光标输入的位置，[code]Vector2i(column, line)[/code]。
var _nearest_input_position : Dictionary[int, Vector2i]
#endregion

@export_group("behavior")
## 判断为非人类输入的最大输入间隔。[br]
## 用于修复部分设备粘贴靠快速输入导致换行缩进问题。
@export var unmanned_input_max_delta := 5
## 连续退格最大忽略时间差。就是快速退格时不在尝试补全的灵敏度。
@export var backspace_ignore_completion_max_delta := 200
## 设置光标位置时，垂直滚动栏行数偏移量。
@export var set_caret_position_scroll_vertical_offset := -3.0

# 行的 id。
var _line_ids : PackedInt32Array = [0]
# 下一行的 id。
var _next_line_id := 1

#region 输入。
## 设置双击映射表。
func set_double_input_map(value : Dictionary[String, String]) -> void:
	double_input_map = value
	for key in value:
		_double_input_map_compiled[ord(key)] = value[key]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ENTER:
				for i in range(get_caret_count()):
					_add_edit_line(get_caret_line(i) + 1)
					_nearest_input_unicode[i] = UNICODE_ENTER
					_nearest_input_time[i] = Time.get_ticks_msec()
			if event.keycode == KEY_TAB:
				for i in range(get_caret_count()):
					var interval : int = Time.get_ticks_msec() - _nearest_input_time.get(i, 0)
					if interval < unmanned_input_max_delta and _nearest_input_unicode.get(i, -1) == UNICODE_ENTER:
						for j in get_line(get_caret_line(i)).length():
							backspace(i)
					_nearest_input_unicode[i] = UNICODE_TAB
					_nearest_input_time[i] = Time.get_ticks_msec()
# 输入字符串。
func _handle_unicode_input(unicode_char: int, caret_index: int) -> void:
	if caret_index == -1:
		for i in range(get_caret_count()):
			caret_unicode_input(unicode_char, i)
	elif caret_index >= 0:
		caret_unicode_input(unicode_char, caret_index)
	await get_tree().process_frame # 等待高亮结果生成
	add_code_hint()
# 退格。
func _backspace(caret_index: int) -> void:
	var test_index : int = 0 if caret_index == -1 else caret_index
	
	var is_backspace := _nearest_input_unicode.get(test_index, -1) as int == UNICODE_BACKSPACE
	var delta : int = Time.get_ticks_msec() - _nearest_input_time[test_index] if is_backspace and _nearest_input_time.has(test_index) else 0xFFFFFFFF
	
	if caret_index >= 0:
		_caret_backspace(caret_index)
	elif caret_index == -1:
		for i in range(get_caret_count()):
			_caret_backspace(i)
	else:
		push_error("异常光标序列 %d." % [caret_index])
	
	await get_tree().process_frame
	if not (is_backspace and delta < backspace_ignore_completion_max_delta): # 连续退格不尝试补全
		add_code_hint()
	else:
		clear_hint()
# 光标处退格。
func _caret_backspace(caret_index := 0) -> void:
	_nearest_input_time[caret_index] = Time.get_ticks_msec()
	_nearest_input_position[caret_index] = Vector2i(get_caret_column(caret_index), get_caret_line(caret_index))
	_nearest_input_unicode[caret_index] = UNICODE_BACKSPACE
	caret_backspace(caret_index)
# 双击事件。
func _double_input(unicode_chr : int, caret_index : int) -> bool:
	if double_input_disabled:
		return false
	if not _double_input_map_compiled.has(unicode_chr):
		return false
	backspace(caret_index)
	caret_insert_text(_double_input_map_compiled[unicode_chr], caret_index)
	return true
#endregion

#region 补全。
## 虚函数，对光标处进行补全。
func _add_code_hint() -> void:
	return
## 清空所有补全提示。
func clear_hint() -> void:
	cancel_code_completion()
	set_code_hint("")
## 批量加入补全数据。
func add_code_completion_data(data : CodeCompletionData) -> void:
	if data == null:
		set_code_hint("")
		return
	set_code_hint(data.hint_string)
	if not data.is_suppled():
		data.supple()
	var kinds := data.kinds
	var display_texts := data.display_texts
	var insert_texts := data.insert_texts
	var text_colors := data.text_colors
	var icons := data.icons
	var values := data.values
	var locations := data.locations
	for i in data.size():
		add_code_completion_option(kinds[i], display_texts[i], insert_texts[i], text_colors[i], icons[i], values[i], locations[i])

## 补全，对光标处进行补全。
func add_code_hint() -> void:
	_add_code_hint()
#endregion

#region 光标。
## 获取光标位置， [code]Vector2i(column, line)[/code]。
func get_caret_position(index := 0) -> Vector2i:
	return Vector2i(get_caret_column(index), get_caret_line(index))
## 设置光标位置。
func set_caret_position(pos := Vector2i(), index := 0) -> void:
	var line := maxi(0, mini(get_line_count(),pos.y))
	set_caret_line(line, index)
	var l := get_line(line).length()
	set_caret_column(maxi(0, mini(l, pos.x)), index)
	scroll_vertical = float(line) + set_caret_position_scroll_vertical_offset
## 对光标处进行输入。
func caret_unicode_input(unicode_char : int, caret_index : int) -> void:
	var interval : int = Time.get_ticks_msec() - _nearest_input_time.get(caret_index, 0)
	if interval < unmanned_input_max_delta: # 视为机器输入，解决换行缩进问题。
		if _nearest_input_unicode.get(caret_index, -1) == UNICODE_ENTER:
			for i in get_line(get_caret_line(caret_index)).length():
				backspace(caret_index)
		caret_insert_text(String.chr(unicode_char), caret_index)
		return
	if interval < double_input_interval_time and unicode_char == _nearest_input_unicode.get(caret_index, -1): # 双击
		if _double_input(unicode_char, caret_index):
			return
	caret_insert_text(String.chr(unicode_char), caret_index)
## 对光标处进行退格。
func caret_backspace(caret_index : int) -> void:
	if has_selection(caret_index):
		remove_area(get_selection_from_line(caret_index), get_selection_from_column(caret_index),
			get_selection_to_line(caret_index), get_selection_to_column(caret_index))
		return
	var to_line := get_caret_line(caret_index)
	var to_column := get_caret_column(caret_index)
	var from_line := to_line
	var from_column := to_column - 1
	if from_column == -1:
		from_line -= 1
		_remove_edit_line(to_line)
		from_column = get_line(from_line).length()
		if from_line == -1:
			return
	remove_text(from_line, from_column, to_line, to_column)
## 在光标处进行插入字符。
func caret_insert_text(txt : String, caret_index := 0) -> void:
	_nearest_input_position[caret_index] = Vector2i(get_caret_column(), get_caret_line())
	insert_text_at_caret(txt, caret_index)
	_nearest_input_unicode[caret_index] = ord(txt.right(1))
	_nearest_input_time[caret_index] = Time.get_ticks_msec()
## 获取关标最近一次输入的时间差，单位ms。
func get_caret_nearest_input_time_delta(index := 0) -> int:
	return Time.get_ticks_msec() - _nearest_input_time[index] if _nearest_input_time.has(index) else -1
## 获取光标最近一次输入的字符码。
func get_caret_nearest_input_unicode(index := 0) -> int:
	return _nearest_input_unicode.get(index, 0)
## 获取光标最近一次输入的位置。
func get_caret_nearest_input_position(index := 0) -> Vector2i:
	return _nearest_input_position.get(index, Vector2i(-1, -1))
#endregion

#region 文本。
## 移除一块区域的文本。[br]
## [b]注意：[/b]如果使用传统的 [method remove_text]，不会发射 [signal line_removed]。
func remove_area(from_line : int, from_column : int, to_line : int, to_column : int) -> void:
	for i in range(to_line, from_line, -1):
		_remove_edit_line(i)
	remove_text(from_line, from_column, to_line, to_column)
## 重置每行的 ID 使他的数量为 [param count]。
func reset_line_ids(count : int) -> void:
	_line_ids.clear()
	_next_line_id = count
	
	var old := _line_ids
	_line_ids = range(count)
	line_id_reseted.emit(old, _line_ids)
#endregion

#region 行。
## 获取指定行的 ID。行 ID 不会因为行的插入和减去而变化。
func get_line_id(line : int) -> int:
	return _line_ids[line]
## 行，获取行序列。
func get_line_index(id : int) -> int:
	# 由于很少插入行，当 ID 较大，很可能在末尾，反之，很可能在开头。
	@warning_ignore("integer_division")
	return _line_ids.find(id) if id < _next_line_id / 2 else _line_ids.rfind(id)

# 新的行被加入。
func _add_edit_line(line : int) -> void:
	_line_ids.insert(line, _next_line_id)
	_next_line_id += 1
	line_added.emit(line, _next_line_id - 1)
# 移除某个行。
func _remove_edit_line(line : int) -> void:
	var id := get_line_id(line)
	_line_ids.remove_at(line)
	line_removed.emit(line, id)
#endregion
