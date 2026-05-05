class_name SelectorElement
extends StringElement
## 目标选择器。

## 头的类型。
const HEAD_TYPE : PackedStringArray = ["a", "e", "r", "p", "s"]

# 头部补全用的数据。
static var _code_completion_head_data : CodeCompletionData
# 如果是 [code]true[/code]，则采用的玩家名称。
var _is_player_name := false
## 身体的括号。
var _body_backet : EqualParamBacketElement
## 头部结束位置。
var head_end := -1

func _init() -> void:
	if _code_completion_head_data == null: _initial_code_completion_head()

func _get_highlight(edit : FunctionEdit) -> Dictionary[int, Dictionary]:
	var result : Dictionary[int, Dictionary]
	result.merge({get_head_start() : {"color" : edit.color_selector}, get_head_end() : {"color" : edit.color_default}})
	if has_body():
		result.merge(_body_backet.get_highlight(edit), true)
	return result
static func get_precast_code_completion_data(_column : int, rule : ElementRule, _command : CommandElement) -> CodeCompletionData:
	if _code_completion_head_data == null: _initial_code_completion_head()
	var data := SelectorElement._code_completion_head_data
	data.hint_string = "<%s : selector>" % [rule.get_description()]
	return data
func _get_column_code_completion_data(column : int, rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data : CodeCompletionData
	
	# 头部
	if not is_valid_head():
		data = _code_completion_head_data
		data.hint_string = "<%s : selector>" % [rule.get_description()]
	# 身体
	elif not has_body():
		return CodeCompletionData.create_backet_data(GrammerValue.Type.ARRAY)
	else:
		if _body_backet.has_column(column):
			return _body_backet.get_column_code_completion_data(column, rule, command)
	return data

static var _selector_search_regex := RegEx.create_from_string((r"^(?<start>\p{Z}*)(?<begin>@)(?<head>\p{L}+)?( *(?<body_begin>\[))?"))
static func create(text : String, offset : int) -> SelectorElement:
	var element := WordElement._create_word_element(SelectorElement.new(), text, offset) as SelectorElement
	if element.is_faild:
		return _create_selector_from_art(text, offset)
	else:
		element._is_player_name = true
		return element
static func _create_selector_from_art(text : String, offset : int) -> SelectorElement:
	var element := SelectorElement.new()
	element.string_offset = offset
	
	var result := _selector_search_regex.search(text.substr(offset))
	if result == null:
		element.create_error(offset, "Not find any string.")
		return element
	
	if result.get_start("begin") == -1:
		element.create_error(result.get_start("body_begin"), "Not is begin with \"@\".")
		return element
	
	element.string = result.get_string()
	element.valid_start = result.get_end("start")
	element.head_end = result.get_end("head")
	
	if result.get_start("body_begin") == -1:
		element.is_faild = false
		return element
	
	var backet := EqualParamBacketElement.create(text, result.get_start("body_begin") + offset, "[", "]", EditManager.get_grammer_law().get_selector_body_rule())
	if backet.is_faild:
		element.is_faild = false
		return element
	
	element.string = text.substr(offset, backet.get_valid_end() - offset)
	element.string_offset = offset
	element._body_backet = backet
	element.is_faild = false
	return element

## 获取头部开始位置。
func get_head_start() -> int:
	is_faild_assert()
	return get_valid_start()
## 获取头部结束位置。
func get_head_end() -> int:
	is_faild_assert()
	return string.length() + string_offset if head_end == -1 else head_end + string_offset
## 获取身体开始位置。
func get_body_start() -> int:
	is_faild_assert()
	return _body_backet.get_valid_start() if _body_backet != null else -1
## 获取身体结束位置。
func get_body_end() -> int:
	is_faild_assert()
	return _body_backet.get_valid_end() if _body_backet != null else -1
## 获取头部字符串。
func get_head_string() -> String:
	is_faild_assert()
	var start := string.find("@") + 1
	return string.substr(start, _body_backet.string_offset - start if _body_backet != null else -1)
## 获取身体字节。
func get_body_string() -> String:
	is_faild_assert()
	return _body_backet.get_backeted_string() if _body_backet != null else ""
## 如果头部有效返回 [code]true[/code]。
func is_valid_head() -> bool:
	return not get_head_string().is_empty()
## 获取身体。
func get_body_element() -> EqualParamBacketElement:
	return _body_backet
## 是否含有身体。
func has_body() -> bool:
	is_faild_assert()
	return _body_backet != null
## 如果是玩家名称，返回 [code]true[/code]。
func is_player_name() -> bool:
	return _is_player_name

## 判断是否为目标选择器。
static func is_selector(text : String) -> bool:
	if text.is_empty():
		return false
	if not text.begins_with("@"):
		return false
	if text.length() > 1:
		return true
	return false

## 返回可用的头部。
static func _get_head_types() -> PackedStringArray:
	var arr : PackedStringArray
	arr.resize(HEAD_TYPE.size())
	for i in HEAD_TYPE.size():
		arr[i] = "@" + HEAD_TYPE[i]
	return arr

# 初始化头部补全数据。
static func _initial_code_completion_head() -> void:
	var data := CodeCompletionData.new()
	data.insert_texts.append_array(_get_head_types())
	data.fill_insert_mode(CodeCompletionData.InsertMode.SELECTOR)
	data.fill_inserted_update(true)
	data.supple()
	_code_completion_head_data = data
