extends Node
## 编辑器的管理。
##
## 全局单例。

# 编辑器默认高亮颜色。
const _EDIT_DEFAULT_HIGHTLIGHT_COLOR : Dictionary[StringName, Color] = {
	&"default" : Color("ffffffbf"),
	&"annotation" : Color("829098c6"),
	&"normal_command_head" : Color("ff4f8b"),
	&"native_command_head" : Color("ff51e5"),
	&"comment_command_head" : Color("ff765c"),
	&"number" : Color("a1ffe0"),
	&"member" : Color("bce0ff"),
	&"point_path_mumber" : Color("92ceffff"),
	&"option" : Color("ff8ccc"),
	&"error_option" : Color("ff51a7"),
	&"bool" : Color("ff6ac2"),
	&"selector" : Color("ffbf66"),
	&"space" : Color("8fffdb"),
	&"stringname" : Color("ffbf66"),
	&"string" : Color("ffeda1"),
	&"special" : Color("5b9dff"),
	&"coord_x" : Color(0.8, 0.2, 0.2),
	&"coord_y" : Color(0.2, 0.8, 0.2),
	&"coord_z" : Color(0.2, 0.6, 0.8),
	&"coord_w" : Color(0.8, 0.2, 0.6),
}

## 编辑器。
var function_edit : FunctionEdit

## 如果有编辑器，返回 [code]true[/code]。
func has_edit() -> bool:
	return function_edit != null
## 返回当前编辑器。
func get_edit() -> FunctionEdit:
	return function_edit

## 返回编辑器补全设置。
func get_completion_setting() -> FunctionCompletionSetting:
	return function_edit.completion_setting
## 返回语法。
func get_grammar() -> Grammar:
	return function_edit.grammar
## 返回语法流程。
func get_grammar_process() -> GrammarProcess:
	return function_edit.grammar.get_process(Grammar.ProcessType.NORMAL)
## 返回本地语法流程。
func get_grammar_native_process() -> GrammarProcess:
	return function_edit.grammar.get_process(Grammar.ProcessType.NATIVE)
## 返回注解进程。
func get_grammar_comment_process() -> GrammarProcess:
	return function_edit.grammar.get_process(Grammar.ProcessType.COMMENT)
## 获取规则。
func get_grammar_law() -> GrammarLaw:
	return function_edit.grammar.get_law()
## 获取补全项。
func get_grammar_entry() -> GrammarEntry:
	return function_edit.grammar.get_entry()

## 获取编辑器默认高亮颜色。
func get_edit_default_hightlight_color(id : StringName) -> Color:
	return _EDIT_DEFAULT_HIGHTLIGHT_COLOR.get(id, Color.BLACK)
