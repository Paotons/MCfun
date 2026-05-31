class_name CommentCommandElementCreater
extends ProcessCommandElementCreater
## 本地指令的创建者。

class _Executer extends RefCounted:
	## 指令。
	var command : CommentCommandElement
	
	func _execute() -> void:
		return

class _ListEdecuter extends _Executer:
	enum ListMode {
		# 加入模式。
		ADD,
	}
	
	func _execute() -> void:
		var type := _get_list_type()
		var mode := _get_list_mode()
		
		if mode == ListMode.ADD:
			var string := _get_added_string()
			command.clear_cmd_list()
			command.add_cmd_list(type, string, -1)
	
	# 返回列表类型。
	func _get_list_type() -> String:
		const LIST_TYPE_INDEX := 0
		return (command.get_element(LIST_TYPE_INDEX) as WordElement).get_valid_string()
	# 返回列表模式。
	func _get_list_mode() -> ListMode:
		var LIST_MODE_INDEX := 1
		@warning_ignore("int_as_enum_without_cast")
		return (command.get_element(LIST_MODE_INDEX) as OptionElement).get_option_index()
	# 如果是 ADD ，返回加入的字符串。
	func _get_added_string() -> String:
		const ADDED_STRIG_INDEX := 2
		return (command.get_element(ADDED_STRIG_INDEX) as StringElement).get_valid_string()

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

func _do_command_tail(text : String, process : CommandElementCreaterProcess) -> void:
	super(text, process)
	_execute()

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

# 执行。
func _execute() -> void:
	if get_command().has_error():
		return
	
	var obj : _Executer
	match get_command().head_string:
		"list": obj = _ListEdecuter.new()
		_: return
	
	obj.command = get_command()
	obj._execute()


