@abstract
class_name BaseCommandExporter
extends Exporter
## 指令导出的基类。
##
## 抽象类，你不应该实例化。

## 当前解析的指令。
var command : BaseCommandElement

## 设置指令。
func set_command(cmd : BaseCommandElement) -> void:
	command = cmd
