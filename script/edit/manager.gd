extends Node
## 编辑器的管理。
##
## 全局单例。

# 编辑器默认高亮颜色。
const _EDIT_DEFAULT_HIGHTLIGHT_COLOR : Dictionary[StringName, Color] = {
	&"default" : Color("ffffffbf"),
	&"key_word" : Color("ff7085"),
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
## 获取当前编辑器。
func get_edit() -> FunctionEdit:
	return function_edit
## 获取语法流程。
func get_grammer_process() -> GrammerProcess:
	return function_edit.grammer.get_process()
## 获取规则。
func get_grammer_law() -> GrammerLaw:
	return function_edit.grammer.get_law()
## 获取补全项。
func get_grammer_entry() -> GrammerEntry:
	return function_edit.grammer.get_entry()

## 获取编辑器默认高亮颜色。
func get_edit_default_hightlight_color(id : StringName) -> Color:
	return _EDIT_DEFAULT_HIGHTLIGHT_COLOR.get(id, Color.BLACK)
