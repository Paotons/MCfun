class_name FunctionSyntaxHighlight
extends SyntaxHighlighter
## 语法高亮。

## 语法。
var grammer_process : GrammerProcess

# 入口。
func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var result := _compute(line)
	var edit := get_text_edit() as FunctionEdit
	
	edit.set_command_element(line, result)
	return result.get_highlight(edit) if result != null else {}

# 开始计算，预处理。
func _compute(line : int) -> CommandElement:
	var edit := get_text_edit()
	var text := edit.get_line(line)
	
	var length := text.length()
	var i := 0
	while i < length:
		if text[i] != "\t":
			return CommandElement.create(text, i, line)
		i += 1
	return null


