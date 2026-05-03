extends Node
## 全局脚本。

## 编辑器。
var edit : FunctionEdit

## 获取编辑器。
func get_edit() -> FunctionEdit:
	return edit
## 获取语法。
func get_grammer() -> GrammerProcess:
	# TEST
	push_warning("Has been replaced by get_grammer process.")
	return edit.grammer_process
## 获取语法流程。
func get_grammer_process() -> GrammerProcess:
	return edit.grammer_process
## 获取规则。
func get_grammer_law() -> GrammerLaw:
	return edit.grammer_law
## 获取补全项。
func get_grammer_entry() -> GrammerEntry:
	return edit.grammer_entry
