@abstract
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
	## 列表。
	LIST,
	## 补全
	COMPLETION,
	## 期望。
	EXPECTATION,
	## 最大。
	MAX,
}
class CMD extends Object:
	@warning_ignore("unused_parameter")
	static func execute(cmd : Array, element : Element, command : BaseCommandElement) -> void:
		return

class _List extends CMD:
	enum ListMode {
		# 添加
		ADD,
	}
	
	static func execute(cmd : Array, element : Element, command : BaseCommandElement) -> void:
		if element == null or element.is_faild:
			return
		var type : String = cmd[2]
		var mode : int = cmd[1]
		if mode == ListMode.ADD: # 添加
			command.add_cmd_list(type, element.get_valid_string(), element.get_valid_start())

class _Completion extends CMD:
	enum CompletionMode {
		# 列表
		LIST,
	}
	
	# 返回补全数据。
	static func get_completion(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
		var data := FunctionCompletionData.new()
		for cmd : Array in rule.get_cmd():
			if cmd[0] != _Head.COMPLETION:
				continue
			var mode : int = cmd[1]
			var edit := EditManager.get_edit()
			if mode == CompletionMode.LIST:
				var list_id : String = cmd[2]
				data.insert_texts.append_array(edit.get_command_cmd_list(list_id, command.get_line_index(), column - 1))
		return data

class _Expectation extends CMD:
	enum ExpectationMode {
		# 清空。
		CLEAR,
	}
	
	static func execute(cmd : Array, _element : Element, command : BaseCommandElement) -> void:
		if cmd[1] == ExpectationMode.CLEAR:
			if command is ProcessCommandElement:
				command.faild_element_idxs.clear()

## 执行指令。
static func execute(element : Element, rule : ElementRule, command : BaseCommandElement, filter := ModeFilter.ALL) -> void:
	for cmd in rule.get_cmd():
		var head : int = cmd[0]
		if filter >> head & 1 != 0:
			continue
		match head:
			_Head.LIST: _List.execute(cmd, element, command)
			_Head.EXPECTATION: _Expectation.execute(cmd, element, command)

## 执行补全，并把补全的数据返回。
static func execute_completion(column : int, rule : ElementRule, command : BaseCommandElement) -> FunctionCompletionData:
	return _Completion.get_completion(column, rule, command)
