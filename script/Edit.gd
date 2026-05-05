class_name FunctionEdit
extends CodeEdit
## 函数编辑器。

#region 输入
@export_group("input")
## 双击输入映射表，双击键值会替换为值，直接更改不会起作用，需要 [method set_double_input_char_map]。
@export var double_input_char_map : Dictionary[String, String] = {
	" " : "\t", # 空格像缩进
	"s" : "§", # 长得像双 s
	"." : "~", # 一点被拉长了
	"," : "^", # 都有弯钩
	"z" : "=", # 像连写的等号
	"n" : "!" , # not 简写
	"a" : "@", # at 简写
	"q" : "{", "p" : "}", # 输入第一排最两边
	"w" : "[", "o" : "]", # 输入法第一排最次两边
	"e" : "<", "i" : ">", # 输入法第一排最次次两边
}
## 双击映射开关。
@export var double_input_disabled := false
## 双击事件最长可识别时间差，单位(ms)。
@export var double_input_interval_time := 256
# 解析过的双击事件映射表。
var _double_input_char_map_compiled : Dictionary[int, String] = {}
## 最近一次光标输入时间。
var nearst_input_time : Dictionary[int, int]
## 最近一次光标输入字符编码。
var nearst_input_unicode : Dictionary[int, int]
#endregion

#region 补全
@export_group("code_expleation")
## 最大补全提示数量。
@export var max_code_expleation := 64
## 如果为 [code]true[/code]，命令空间补全会包含空间名。
@export var spaceitem_expleation_included_space := true

# 对于补全指令头用的补全数据。
static var _code_completion_head_data : CodeCompletionData
#endregion

#region 语法。
@export_group("grammer")
## 直接语法 JS。
@export var grammer_json : JSON
## 语法规则，用于 [member grammer_process] 更精细的操作。
@export var grammer_law_json : JSON
## 初始字符串，用于指令的各种补全。
@export var grammer_entry_json : JSON
## 语法。
var grammer_process : GrammerProcess
## 语法规则。
var grammer_law : GrammerLaw
## 语法字符串。
var grammer_entry : GrammerEntry
#endregion

#region 颜色。
@export_group("color", "color")
## 默字体认颜色。
@export var color_default := Color("ffffffbf")
## 关键字颜色。
@export var color_key_word := Color("ff7085")
## 数字颜色。
@export var color_number := Color("a1ffe0")
## 成员颜色，包含目标选择器里的各种参数或者是 JS 和 NBT 里的参数。
@export var color_member := Color("bce0ff")
## 点号路径成员。
@export var color_point_path_mumber := Color("92ceffff")
## 选项字符颜色。
@export var color_option := Color("ff8ccc")
## 错误选项字符颜色。
@export var color_error_option := Color("ff51a7")
## 布尔颜色。
@export var color_bool := Color("ff6ac2")
## 目标选择器的开头颜色。
@export var color_selector := Color("ffbf66")
## 名称的空间名颜色。
@export var color_space := Color("8fffdb")
## 物品名，实体名等各种名称颜色。
@export var color_stringname := Color("ffbf66")
## 字符串颜色。
@export var color_string := Color("ffeda1")
## 特殊字符，对于 "\n" 或者是其他类似字符串的高亮。
@export var color_special := Color("5b9dff")
#region 坐标。
## x 轴坐标颜色。
@export var color_coord_x := Color(0.8, 0.2, 0.2)
## y 轴坐标颜色。
@export var color_coord_y := Color(0.2, 0.8, 0.2)
## z 轴坐标颜色。
@export var color_coord_z := Color(0.2, 0.6, 0.8)
## w 轴坐标颜色，虽然几乎没怎么用。
@export var color_coord_w := Color(0.8, 0.2, 0.6)
#endregion
#endregion

# 行的 id。
var _line_ids : PackedInt32Array = [0]
# 下一行的 id。
var _next_line_id := 1

## 指令数据。
var command_elements : Dictionary[int, CommandElement]

# 开始。
func _ready() -> void:
	set_double_input_char_map(double_input_char_map)
	#region 初始化语法。
	assert(grammer_json != null, "GrammerProcess is null.")
	assert(grammer_law_json != null, "GrammerProcess runle is null.")
	assert(grammer_entry_json != null, "Completion entry is null.")
	
	grammer_process = GrammerProcess.new()
	if grammer_json != null:
		grammer_process.compile(grammer_json.data)
	var fsh := FunctionSyntaxHighlight.new()
	fsh.grammer_process = grammer_process
	syntax_highlighter = fsh
	
	grammer_law = GrammerLaw.new()
	if grammer_law_json != null:
		grammer_law.compile(grammer_law_json.data)
	
	grammer_entry = GrammerEntry.new()
	if grammer_entry_json != null:
		grammer_entry.compile(grammer_entry_json.data)
	
	EditManager.function_edit = self
	print_rich("[color=#909]本次解析用时 %dms." % [Time.get_ticks_msec()])
	#endregion
	_ready_test()

@warning_ignore("unused_private_class_variable")
# TEST 测试 仅接于 _ready
@export var _test_data : String
func _ready_test() -> void:
	pass

## 获取高亮颜色。
func get_highlight_color(color_name : String) -> Color:
	match color_name:
		"default" : return color_default
		"key_word" : return color_key_word
		"number" : return color_number
		"member" : return color_member
		"point_path_mumber" : return color_point_path_mumber
		"option" : return color_option
		"error_option" : return color_error_option
		"bool" : return color_bool
		"selector" : return color_selector
		"space" : return color_space
		"stringname" : return color_stringname
		"special" : return color_special
		"string" : return color_string
		"coord_x" : return color_coord_x
		"coord_y" : return color_coord_y
		"coord_z" : return color_coord_z
		_:
			push_error("Not has the color \"%s\"." % [color_name])
			return Color()
## 设置高亮颜色。
func set_highlight_color(color_name : String, color : Color) -> void:
	match color_name :
		"default" : color_default = color
		"key_word" : color_key_word = color
		"number" : color_number = color
		"member" : color_member = color
		"point_path_mumber" : color_point_path_mumber = color
		"option" : color_option = color
		"error_option" : color_error_option = color
		"bool" : color_bool = color
		"selector" : color_selector = color
		"space" : color_space = color
		"stringname" : color_stringname = color
		"special" : color_special = color
		"string" : color_string = color
		"coord_x" : color_coord_x = color
		"coord_y" : color_coord_y = color
		"coord_z" : color_coord_z = color
		_:
			push_error("Not has the color \"%s\"." % [color_name])

#region 输入。
## 解析双击事件映射表。
func set_double_input_char_map(value : Dictionary[String, String]) -> void:
	double_input_char_map = value
	for key in value:
		_double_input_char_map_compiled[ord(key)] = value[key]
#
func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ENTER:
				for i in range(get_caret_count()):
					_add_line(get_caret_line(i) + 1)
					nearst_input_unicode[i] = 10 # \n
					nearst_input_time[i] = Time.get_ticks_msec()
			if event.keycode == KEY_TAB:
				for i in range(get_caret_count()):
					var interval : int = Time.get_ticks_msec() - nearst_input_time.get(i, 0)
					if interval < 5 and nearst_input_unicode.get(i, -1) == 10: # 换行
						for j in get_line(get_caret_line(i)).length():
							backspace(i)
					nearst_input_unicode[i] = 9 # \t
					nearst_input_time[i] = Time.get_ticks_msec()
# 字符输入。
func _handle_unicode_input(unicode_char: int, caret_index: int) -> void:
	if caret_index == -1:
		for i in range(get_caret_count()):
			caret_unicode_input(unicode_char, i)
	elif caret_index >= 0:
		caret_unicode_input(unicode_char, caret_index)
	await get_tree().process_frame
	add_code_hint()
# 退格。
func _backspace(caret_index: int) -> void:
	if caret_index >= 0:
		caret_backspace(caret_index)
	elif caret_index == -1:
		for i in range(get_caret_count()):
			caret_backspace(i)
	else:
		push_error("异常光标序列 %d." % [caret_index])
	await get_tree().process_frame
	add_code_hint()
# 双击事件。
func _double_input(unicode_chr : int, caret_index : int) -> bool:
	if double_input_disabled:
		return false
	if not _double_input_char_map_compiled.has(unicode_chr):
		return false
	backspace(caret_index)
	caret_insert_text(_double_input_char_map_compiled[unicode_chr], caret_index)
	return true
#endregion

#region 补全主要。
## 补全，对光标处进行补全。
func add_code_hint() -> void:
	var line := get_caret_line()
	var element := get_command_element(line)
	if element == null or element.is_empty():
		cancel_code_completion()
		set_code_hint("")
		return
	_command_add_code_hint(element, true)
## 补全，清空所有补全提示。
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

# 补全，指令。
func _command_add_code_hint(command : CommandElement, current_update := true) -> void:
	var column := get_caret_column()
	
	var data := command.get_column_code_completion_data(column, null, null)
	add_code_completion_data(data)
	if current_update:
		update_code_completion_options(false)

# 补全，指令头。
func _command_add_code_hint_head() -> void:
	add_code_completion_data(_code_completion_head_data)

#endregion

#region 补全调整。
# 补全调整，排序，入口。
func _filter_code_completion_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
	var column := get_caret_column()
	var line := get_caret_line()
	var line_text := get_line(line)
	
	var result_simlarities : PackedInt32Array
	var results : Array[Dictionary]
	for i in candidates.size():
		var data := candidates[i]
		var result := CodeCompletionData.get_weight(line_text, column, data)
		var index := result_simlarities.bsearch(result)
		result_simlarities.insert(index, result)
		results.insert(index, data)
	
	if results.size() > max_code_expleation:
		results = results.slice(results.size() - max_code_expleation)
	results.reverse()
	return results
#endregion

#region 补全插入。
# 入口。
func _confirm_code_completion(_replace: bool) -> void:
	if _do_confirm_code_completion():
		await get_tree().process_frame
		add_code_hint()
	else:
		cancel_code_completion()
# 补全内容的替换逻辑入口。
func _do_confirm_code_completion() -> bool:
	var index := get_code_completion_selected_index()
	var data := get_code_completion_option(index)
	var line := get_caret_line()
	var column := get_caret_column()
	var line_text := get_line(line)
	var insert : String = data.insert_text
	var value : CodeCompletionDataValue = data.default_value
	
	var from_column := CodeCompletionData.get_insert_start(line_text, column, data)
	var to_column := CodeCompletionData.get_insert_end(line_text, column, data)
	
	set_caret_column(to_column)
	remove_area(line, from_column, line, to_column)
	caret_insert_text(insert)
	
	if value and value.inserted_column_offset != 0:
		column = get_caret_column() + value.inserted_column_offset
		set_caret_column(column)
	return value.inserted_update if value else false
#endregion

#region 光标。
## 光标，输入。
func caret_unicode_input(unicode_char : int, caret_index : int) -> void:
	var interval : int = Time.get_ticks_msec() - nearst_input_time.get(caret_index, 0)
	if interval < 500: # 初筛，非正常差值。
		if interval < 5: # 识别为原生生态的粘贴。
			if nearst_input_unicode.get(caret_index, -1) == 10: # 换行
				for i in get_line(get_caret_line(caret_index)).length():
					backspace(caret_index)
			caret_insert_text(String.chr(unicode_char), caret_index)
			return
		if interval < double_input_interval_time and unicode_char == nearst_input_unicode.get(caret_index, -1): # 双击
			if _double_input(unicode_char, caret_index):
				return
	caret_insert_text(String.chr(unicode_char), caret_index)

## 光标，退格。
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
		_remove_line(to_line)
		from_column = get_line(from_line).length()
		if from_line == -1:
			return
	remove_text(from_line, from_column, to_line, to_column)
## 光标，插入字符串。
func caret_insert_text(txt : String, caret_index := 0) -> void:
	insert_text_at_caret(txt, caret_index)
	nearst_input_unicode[caret_index] = ord(txt.right(1))
	nearst_input_time[caret_index] = Time.get_ticks_msec()
#endregion

#region 文本。
## 文本，移除区域文本[method TextEdit.remove_text]。
func remove_area(from_line : int, from_column : int, to_line : int, to_column : int) -> void:
	for i in range(to_line, from_line, -1):
		print("行 %d 被删除。" % [i])
	remove_text(from_line, from_column, to_line, to_column)
## 设置函数文本。
func set_function_text(txt : String) -> void:
	_line_ids.clear()
	command_elements.clear()
	
	var line = txt.count("\n") + 1
	_next_line_id = line
	_line_ids = range(line)
	
	set_text(txt)

#endregion

#region 指令。
## 指令，设置数据。
func set_command_element(line : int, element : CommandElement) -> void:
	var id := get_line_id(line)
	command_elements[id] = element
	_errors_list_changed()
## 指令，获取数据。
func get_command_element(line : int) -> CommandElement:
	return command_elements.get(get_line_id(line))
## 指令，获取有错误的指令。
func find_has_error_command(from_line := 0, to_line := -1) -> int:
	if to_line == -1:
		to_line = _line_ids.size() - 1
	var i := from_line
	while i <= to_line:
		var element := get_command_element(i)
		if element == null:
			i += 1
			continue
		if element.has_error():
			return i
		else:
			i += 1
	return -1
## 指令，查找前方指令的列表。
func get_command_cmd_list(id : int, line : int, column : int) -> PackedStringArray:
	var init_ele := get_command_element(line)
	var result := init_ele.get_cmd_list(id, column) if init_ele != null else PackedStringArray()
	var hash_map : Dictionary[int, bool]
	for i in range(line - 1, maxi(-1, line - 501), -1):
		var element := get_command_element(i)
		if element == null:
			continue
		
		for arr : String in element.get_cmd_list(id):
			var hash_ := arr.hash()
			if not hash_map.has(hash_):
				result.append(arr)
				hash_map[hash_] = false
	return result
#endregion

#region 行。
## 行，获取 ID。
func get_line_id(line : int) -> int:
	return _line_ids[line]
## 行，获取行序列。
func get_line_index(id : int) -> int:
	# 由于很少插入行，当 ID 较大，很可能在末尾，反之，很可能在开头。
	@warning_ignore("integer_division")
	return _line_ids.find(id) if id < _next_line_id / 2 else _line_ids.rfind(id)

# 文本，行加入。
func _add_line(line : int) -> void:
	_line_ids.insert(line, _next_line_id)
	_next_line_id += 1
# 文本，行移除。
func _remove_line(line : int) -> void:
	var id := get_line_id(line)
	_line_ids.remove_at(line)
	command_elements.erase(id)
#endregion

## 错误列表发生改变。
func _errors_list_changed() -> void:
	return

func _exit_tree() -> void:
	EditManager.function_edit = null
