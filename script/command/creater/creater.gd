class_name CommandElementCreater
extends ProcessCommandElementCreater
## 指令元素创建者。
##
## 用于创建 [CommandElement] 的。

## 从零开始处理指令。
func run_from_empty(text : String, process : CommandElementCreaterProcess) -> void:
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
	var result := HeadElement.create(text, process.offset) as HeadElement
	
	for err in result.errors: create_error(err.column, err.string)
	if result.is_faild: return false
	get_command().is_faild = false
	get_command().valid_start = result.get_valid_start() - process.offset
	
	var head := result.get_valid_string()
	
	_get_hl_data().merge(result.get_highlight(process.edit))
	get_command().head_element = result
	get_command().head_string = head
	
	if not process.grammar.has_head(head):
		create_error(result.get_valid_start(), "Not has head \"%s\"." % [head])
		return false
	
	process.offset = result.get_valid_end()
	return true
