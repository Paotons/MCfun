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
	var command := edit.get_command_element(line)
	var text := edit.get_line(line)
	if command == null:
		var length := text.length()
		var i := 0
		while i < length:
			if text[i] != "\t":
				return CommandElement.create(text, i, line)
			i += 1
		return null
	else:
		var position := edit.get_caret_nearest_input_position()
		return command.update(text, position.x)


