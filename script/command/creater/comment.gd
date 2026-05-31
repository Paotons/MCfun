class_name CommentCommandElementCreater
extends ProcessCommandElementCreater
## 本地指令的创建者。

## 完全从无开始创建。
func run_from_empty(text : String, process : CommandElementCreaterProcess) -> void:
	if text[process.offset] != "@":
		create_error(0, "Comment command should begin with \"@\".")
		return get_command()
	
	get_command().is_faild = false
	get_command().valid_start = 0
	_get_hl_data().merge({process.offset : {"color" : process.edit.color_comment_command_head}, process.offset + 1 : {"color" : process.edit.color_default}})
	process.offset += 1
	
	if not _do_head(text, process):
		return
	
	var head := get_command().head_element.get_valid_head()
	process.rule = process.grammar.get_command_rule(head)
	process.exe_index = 0
	process.exe_end = process.rule.get_element_count()
	_do_command_process(text, process)
	_do_command_tail(text, process)

# 处理开头。
func _do_head(text : String, process : CommandElementCreaterProcess) -> bool:
	var result := HeadElement.create(text, process.offset, CommandElementManager.CommandType.COMMENT) as HeadElement
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return false
	
	var head := result.get_valid_string()
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	get_command().head_element = result
	get_command().head_string = head
	
	if not process.grammar.has_head(head):
		create_error(result.get_valid_start(), "Unfind get_command() \"%s\"." % [head])
		return false
	
	process.offset = result.get_valid_end()
	return true

