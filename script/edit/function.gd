class_name FunctionEdit
extends CustomCodeEdit
## 函数编辑器。
##
## 补全的插入有改动，如果 [code]display_text[/code] 为空，则显示 [code]insert_text[/code]。

## 默认双击映射。
const DEFAULT_DOUBLE_INPUT_MAP : Dictionary[String, String] = {
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

## 指令数据。
var command_elements : Dictionary[int, BaseCommandElement]
## 语法。
var grammar : Grammar

@export_group("code_expleation")
## 最大补全提示数量。
@export var max_code_expleation := 64
## 补全设置。
@export var completion_setting := FunctionCompletionSetting.new()

#region 颜色。
@export_group("color", "color")
## 默字体认颜色。
@export var color_default := Color("ffffffbf")
## 注释颜色。
@export var color_annotation := Color("829098c6")
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

func _ready() -> void:
	line_added.connect(_on_line_added)
	line_removed.connect(_on_line_removed)
	
	set_double_input_map(DEFAULT_DOUBLE_INPUT_MAP)
	EditManager.function_edit = self
	
	# TEST 测试。
	_ready_test()

func _exit_tree() -> void:
	EditManager.function_edit = null

func _add_code_hint() -> void:
	if grammar == null:
		return
	
	var line := get_caret_line()
	var element := get_command_element(line)
	if element == null or element.is_empty():
		cancel_code_completion()
		set_code_hint("")
		return
	_command_add_code_hint(element, true)

func _filter_code_completion_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
	var column := get_caret_column()
	var line := get_caret_line()
	var line_text := get_line(line)
	
	var using_hint_word := completion_setting.using_hint_word_weight
	var result_simlarities : PackedInt32Array
	var results : Array[Dictionary]
	for i in candidates.size():
		var data := candidates[i]
		var weight := FunctionCompletionData.get_weight(line_text, column, data, using_hint_word)
		
		var index := result_simlarities.bsearch(weight)
		result_simlarities.insert(index, weight)
		results.insert(index, data)
	
	if results.size() > max_code_expleation:
		results = results.slice(results.size() - max_code_expleation)
	results.reverse()
	
	var disabled_hint_word := not completion_setting.showing_hint_word
	for result : Dictionary in results:
		var display : String = result["display_text"]
		var insert : String = result["insert_text"]
		result["display_text"] = insert if disabled_hint_word or display.is_empty() else insert + "   (" + display + ")"
	return results

func _confirm_code_completion(_replace: bool) -> void:
	if _do_confirm_code_completion():
		await get_tree().process_frame
		add_code_hint()
	else:
		cancel_code_completion()

# 对指令进行补全。
func _command_add_code_hint(command : BaseCommandElement, current_update := true) -> void:
	var column := get_caret_column()
	
	var data := null if command.is_faild else command.get_column_code_completion_data(column, null, null)
	add_code_completion_data(data)
	if current_update:
		update_code_completion_options(false)

# 进行补全内容的替换。
func _do_confirm_code_completion() -> bool:
	var index := get_code_completion_selected_index()
	var data := get_code_completion_option(index)
	var line := get_caret_line()
	var column := get_caret_column()
	var line_text := get_line(line)
	var insert : String = data.insert_text
	var value : FunctionCompletionDataValue = data.default_value
	
	var from_column := FunctionCompletionData.get_insert_start(line_text, column, data)
	var to_column := FunctionCompletionData.get_insert_end(line_text, column, data)
	
	set_caret_column(to_column)
	custom_remove_text(line, from_column, line, to_column)
	caret_insert_text(insert)
	
	if value and value.inserted_column_offset != 0:
		column = get_caret_column() + value.inserted_column_offset
		set_caret_column(column)
	return value.inserted_update if value else false

#region 测试。
@warning_ignore("unused_private_class_variable")
# TEST 测试 仅接于 _ready
@export var _test_data : String
func _ready_test() -> void:
	pass
#endregion

## 获取高亮颜色。
func get_highlight_color(color_name : StringName) -> Color:
	match color_name:
		&"default" : return color_default
		&"annotation" : return color_annotation
		&"key_word" : return color_key_word
		&"number" : return color_number
		&"member" : return color_member
		&"point_path_mumber" : return color_point_path_mumber
		&"option" : return color_option
		&"error_option" : return color_error_option
		&"bool" : return color_bool
		&"selector" : return color_selector
		&"space" : return color_space
		&"stringname" : return color_stringname
		&"special" : return color_special
		&"string" : return color_string
		&"coord_x" : return color_coord_x
		&"coord_y" : return color_coord_y
		&"coord_z" : return color_coord_z
		_:
			push_error("Not has the color \"%s\"." % [color_name])
			return Color()
## 设置高亮颜色。
func set_highlight_color(color_name : StringName, color : Color) -> void:
	match color_name :
		&"default" : color_default = color
		&"annotation" : color_annotation = color
		&"key_word" : color_key_word = color
		&"number" : color_number = color
		&"member" : color_member = color
		&"point_path_mumber" : color_point_path_mumber = color
		&"option" : color_option = color
		&"error_option" : color_error_option = color
		&"bool" : color_bool = color
		&"selector" : color_selector = color
		&"space" : color_space = color
		&"stringname" : color_stringname = color
		&"special" : color_special = color
		&"string" : color_string = color
		&"coord_x" : color_coord_x = color
		&"coord_y" : color_coord_y = color
		&"coord_z" : color_coord_z = color
		_:
			push_error("Not has the color \"%s\"." % [color_name])

#region 指令。
## 返回指定行数的指令的数据。
func set_command_element(line : int, element : BaseCommandElement) -> void:
	var id := get_line_id(line)
	command_elements[id] = element
	_errors_list_changed()
## 返回指定行行数的指令的数据。
func get_command_element(line : int) -> BaseCommandElement:
	return command_elements.get(get_line_id(line))
## 返回从 [param from_line] 到 [param to_line] 中最近有错误的指令。
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
## 返回从 [param line] 行， [param column] 列向前 [param lenght] 的指令列表中 [param id] 所有的字符串。
func get_command_cmd_list(id : int, line : int, column : int, length := 501) -> PackedStringArray:
	var init_ele := get_command_element(line)
	var result := init_ele.get_cmd_list(id, column) if init_ele != null else PackedStringArray()
	var hash_map : Dictionary[int, bool]
	for i in range(line - 1, maxi(-1, line - length), -1):
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

func set_function_text(value : String) -> void:
	clear_undo_history()
	command_elements.clear()
	var count = value.count("\n") + 1
	reset_line_ids(count)
	clear_hint()
	set_text(value)

## 虚函数，错误列表发生改变。
func _errors_list_changed() -> void:
	return

# HACK 目前还不知道有没有用。
func _on_line_added(_line : int, _line_id : int) -> void:
	pass
func _on_line_removed(_line : int, line_id : int) -> void:
	command_elements.erase(line_id)
