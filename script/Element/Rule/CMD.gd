@abstract @tool
class_name ElementRuleCMD
extends Object
## 静态类，元素规则的指令。

## 过滤。
enum ModeFilter {
	## 全部不过滤。
	ALL = 0,
	## 列表。
	LIST = 1 << 0,
	## 补全。
	COMPLETION = 1 << 1,
}

enum _Head {
	# 列表。
	LIST,
	# 补全
	COMPLETION,
}
enum _ItemListMode {
	# 添加
	ADD,
}
enum _ItemCompletionMode {
	# 列表
	LIST,
}

# 解析指令的正则表达式。
static var _COMPILE_REGEXS : Dictionary[String, RegEx] = {
	"list_add_self" : RegEx.create_from_string(r"^ *list +(?<list_name>\w+) +add +self *$"),
	"completion_list" : RegEx.create_from_string(r"^ *completion +list +(?<list_name>\w+) *$"),
}

#region 执行。
## 执行指令。
static func execute(element : Element, rule : ElementRule, command : CommandElement, filter := ModeFilter.ALL) -> void:
	for cmd in rule.get_cmd():
		var head : int = cmd[0]
		if filter >> head & 1 == 0:
			continue
		match head:
			_Head.LIST: _execute_list(cmd, element, command)
static func _execute_list(cmd : Array, element : StringElement, command : CommandElement) -> void:
	if element == null or element.is_faild: return
	var list_id : int = cmd[2]
	var mode : int = cmd[1]
	if mode == _ItemListMode.ADD: # 添加
		if not command.cmd_list.has(list_id): command.cmd_list[list_id] = {}
		command.cmd_list[list_id][element.get_valid_start()] = element.get_valid_string()
## 执行补全，并把补全的数据返回。
static func execute_completion(column : int, rule : ElementRule, command : CommandElement) -> CodeCompletionData:
	var data := CodeCompletionData.new()
	for cmd : Array in rule.get_cmd():
		if cmd[0] != _Head.COMPLETION:
			continue
		var mode : int = cmd[1]
		var edit := EditManager.get_edit()
		if mode == _ItemCompletionMode.LIST:
			var list_id : int = cmd[2]
			data.insert_texts.append_array(edit.get_command_cmd_list(list_id, command.get_line_index(), column - 1))
	return data
#endregion

#region 解析。
## 解析。
static func compile(from : Dictionary, to : Dictionary) -> bool:
	if from.has("cmd"):
		to[ElementRule.META_CMD] = []
		if typeof(from["cmd"]) == TYPE_ARRAY:
			for value in from["cmd"]:
				if not typeof(value) == TYPE_STRING:
					return true
				else:
					var to_item : Array
					if _compile_item(value, to_item):
						return true
					to[ElementRule.META_CMD].append(to_item)
			return false
		else:
			push_error("Meta named is_end is %s." % [type_string(typeof(from["cmd"]))])
			return true
	return false

# 解析条目。
@warning_ignore("unused_parameter")
static func _compile_item(from : String, to : Array) -> bool:
	for key in _COMPILE_REGEXS:
		var regex := _COMPILE_REGEXS[key]
		var result := regex.search(from)
		if result == null: continue
		match key:
			"list_add_self": return _compile_item_list_add_self(result, to)
			"completion_list" : return _compile_item_completion(result, to)
	push_error("Unvalid cmd \"%s\"." %  [from])
	return true
#region 解析，list。
# 1 -> mode
# 2 -> list_name
static func _compile_item_list_add_self(result : RegExMatch, to : Array) -> bool:
	to.resize(3)
	to[0] = _Head.LIST
	to[1] = _ItemListMode.ADD
	to[2] = result.get_string("list_name").hash()
	return false
#endregion
#region 解析，completion。
# 1 -> mode
# 2 -> so on.
static func _compile_item_completion(result : RegExMatch, to : Array) -> bool:
	to.resize(3)
	to[0] = _Head.COMPLETION
	to[1] = _ItemCompletionMode.LIST
	to[2] = result.get_string("list_name").hash()
	return false
#endregion
#endregion
