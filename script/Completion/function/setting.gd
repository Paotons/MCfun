class_name FunctionCompletionSetting
extends Resource
## 函数编辑器补全设置。

## 如果为 [code]true[/code]，命令空间补全会包含空间名。
@export var spaceitem_included_space := true
## 如果为 [code]true[/code]，补全路径时会显示全部。
@export var point_path_show_all := true
## 如果为 [code]true[/code]，显示提示词。
@export var showing_hint_word := true
## 如果为 [code]true[/code]，补全会使用提示词。[br]
## [b]注意：[/b]此功能打开会加倍性能消耗。
@export var using_hint_word_weight := true


