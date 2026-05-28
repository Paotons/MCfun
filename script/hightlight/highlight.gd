class_name FunctionSyntaxHighlight
extends SyntaxHighlighter
## 语法高亮。

## 语法。
var grammar_process : GrammarProcess

# 入口。
func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var result := _compute(line)
	var edit := get_text_edit() as FunctionEdit
	
	edit.set_command_element(line, result)
	return result.get_highlight(edit) if result != null else {}

# 开始计算，预处理。
func _compute(line : int) -> CommandElement:
	var edit := get_text_edit() as FunctionEdit
	var unicode := edit.get_caret_nearest_input_unicode()
	var command := edit.get_command_element(line)
	var text := edit.get_line(line)
	if command == null or unicode == -1:
		return _create_command(text, line)
	else:
		var position := edit.get_caret_nearest_input_position()
		return _update_command(command, text, position)

# 创建指令。
func _create_command(text : String, line : int) -> BaseCommandElement:
	var length := text.length()
	var i := 0
	while i < length:
		if text[i] != "\t":
			var command := BaseCommandElement.create(text, i, line)
			command.command_type |= CommandElementManager.CommandType.ROOT
			return command
		i += 1
	return null
# 更新指令。
func _update_command(command : BaseCommandElement, text : String, pos : Vector2i) -> BaseCommandElement:
	var length := text.length()
	var i := 0
	while i < length:
		if text[i] != "\t":
			return command.update(text, pos.x)
		i += 1
	return null


