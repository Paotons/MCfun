@abstract
class_name CommandElementManager
extends Object
## 指令元素的管理。
##
## 静态类，你不应该实例化。

## 指令类型。
enum CommandType {
	## 空指令。
	EMPTY = 1 << 0,
	## 普通指令。
	NORMAL = 1 << 1,
	## 最开始，根部。
	ROOT = 1 << 2,
	## 直接替代原来的父指令，直达最后，类型于 execute run 分支一样。
	REPLACE = 1 << 3,
	## 以问号开头的指令。
	HELP = 1 << 4,
	## 注释。
	ANNOTATION = 1 << 5,
}

# 指令头补全数据。
static var _head_completion_data : FunctionCompletionData
# 语法实例 id。
static var _grammar_instance_id := -1

static func get_head_completion_data(grammar : GrammarProcess = null) -> FunctionCompletionData:
	if grammar == null:
		grammar = EditManager.get_grammar_process()
	
	if grammar.get_instance_id() != _grammar_instance_id:
		var data := FunctionCompletionData.new()
		data.insert_texts.append_array(grammar.get_heads())
		data.fill_insert_mode(FunctionCompletionData.InsertMode.WORLD)
		_head_completion_data = data
	
	return _head_completion_data

