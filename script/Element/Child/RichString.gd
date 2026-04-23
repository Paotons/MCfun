class_name RichStringElement
extends StringElement
## 富文本字符串。

## 符号类别。
enum FlagType {
	## 风格符，即 [code]§[/code]。
	STYLE,
	## 转义符，即 [code]\[/code]。
	ESCAPE,
}

## 特殊符号位置。
var flag_columns : PackedInt32Array
## 特殊符号类别。
var flag_types : Array[FlagType]
## 对于风格符补全数据。
static var STYLE_FLAG_CODE_COMPLETION_DATA : CodeCompletionData

# 风格符后面的字符对应的颜色。
# 由 DeepSeek 生成，有问题找它。
const _STYLE_FLAG_COLOR_MAP : Dictionary[int, Color] = {
	# 数字
	0x30: Color(0, 0, 0),        # '0' black
	0x31: Color(0, 0, 0.545),    # '1' dark_blue
	0x32: Color(0, 0.545, 0),    # '2' dark_green
	0x33: Color(0, 0.545, 0.545),# '3' dark_aqua
	0x34: Color(0.545, 0, 0),    # '4' dark_red
	0x35: Color(0.545, 0, 0.545),# '5' dark_purple
	0x36: Color(0.545, 0.353, 0),# '6' gold
	0x37: Color(0.545, 0.545, 0.545),# '7' gray
	0x38: Color(0.353, 0.353, 0.353),# '8' dark_gray
	0x39: Color(0.353, 0.353, 1),# '9' blue
	
	# 小写字母
	0x61: Color(0.353, 1, 0.353),# 'a' green
	0x62: Color(0.353, 1, 1),    # 'b' aqua
	0x63: Color(1, 0.353, 0.353),# 'c' red
	0x64: Color(1, 0.353, 1),    # 'd' light_purple
	0x65: Color(1, 1, 0.353),    # 'e' yellow
	0x66: Color(1, 1, 1),        # 'f' white
}
# 特殊符号标签。
const _STYLE_FLAG_SPECAIL : PackedInt32Array = [
	# 格式化
	0x6b, # 'k' 随机
	0x6c, # 'l' 加粗
	0x6d, # 'm' 删除线
	0x6e, # 'n' 下划线
	0x6f, # 'o' 斜体
	0x72, # 'r' 重置
]

func _get_hightlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var length := get_valid_end()
	var result : Dictionary[int, Dictionary]
	var nearst_color := edit.color_default
	for i in flag_columns.size():
		var column := flag_columns[i] + string_offset
		match flag_types[i]:
			FlagType.STYLE:
				if column + 1 >= length:
					result[column] = {"color" : edit.color_special}
					continue
				var next_ord := ord(string[column - string_offset + 1])
				if _STYLE_FLAG_COLOR_MAP.has(next_ord):
					nearst_color = _STYLE_FLAG_COLOR_MAP[next_ord]
					result[column] = {"color" : nearst_color}
				else:
					result[column] = {"color" : edit.color_special}
					result[column + 2] = {"color" : nearst_color}
			FlagType.ESCAPE:
				if column + 1 >= length:
					result[column] = {"color" : edit.color_special}
					continue
				result[column] = {"color" : edit.color_special}
				result[column + 2] = {"color" : nearst_color}
	result[get_valid_end()] = {"color" : edit.color_default}
	return result
func _get_column_code_completion_data(column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : rich_string>" % [rule.get_description()]
	var index := flag_columns.find(column - string_offset - 1)
	index = flag_columns.find(column - string_offset - 2) if index == -1 else index
	if index == -1: return data
	
	var type := flag_types[index]
	if type == FlagType.ESCAPE:
		data.insert_texts.append("n")
	elif type == FlagType.STYLE:
		return STYLE_FLAG_CODE_COMPLETION_DATA
	return data
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	data.hint_string = "<%s : rich_string>" % [rule.get_description()]
	return data

static func create(text : String, offset : int) -> RichStringElement:
	var element := RichStringElement.new()
	element.string_offset = offset
	
	var result := StringElement.create(text, offset)
	if result.is_faild:
		element.create_error(offset, "Not find any string.")
		return element
	element.valid_start = result.get_valid_start() - offset
	
	element.string = text.substr(offset, result.get_valid_end() - offset)
	element.is_faild = false
	
	if element.is_faild:
		return element
	
	var valid_str := element.string
	var i := element.valid_start
	var length := valid_str.length()
	while i < length:
		match valid_str[i]:
			"\\":
				element.flag_columns.append(i)
				element.flag_types.append(FlagType.ESCAPE)
				i += 1
			"§":
				element.flag_columns.append(i)
				element.flag_types.append(FlagType.STYLE)
				i += 1
		i += 1
	return element

func _init() -> void:
	if STYLE_FLAG_CODE_COMPLETION_DATA == null:
		_style_code_completion_data_initial()

# 初始化风格补全数据。
static func _style_code_completion_data_initial() -> void:
	var data := CodeCompletionData.new()
	for chr in _STYLE_FLAG_COLOR_MAP:
		var color := _STYLE_FLAG_COLOR_MAP[chr]
		data.insert_texts.append(char(chr))
		data.text_colors.append(color)
	for chr in _STYLE_FLAG_SPECAIL:
		data.insert_texts.append(char(chr))
	data.supple()
	STYLE_FLAG_CODE_COMPLETION_DATA = data
