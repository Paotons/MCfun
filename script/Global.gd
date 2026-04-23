extends Node
## 全局脚本。

## 编辑器。
var edit : FunctionEdit

## 获取编辑器。
func get_edit() -> FunctionEdit:
	return edit
## 获取语法。
func get_grammer() -> Grammer:
	return edit.grammer
## 获取规则。
func get_grammer_law() -> GrammerLaw:
	return edit.grammer_law
## 获取补全项。
func get_grammer_entry() -> GrammerEntry:
	return edit.grammer_entry
