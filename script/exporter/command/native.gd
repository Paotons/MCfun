class_name NativeCommandExporter
extends BaseCommandExporter
## 本地指令的导出。

var parser_values := NativeCommandElementParserValues.new()

@warning_ignore("unused_parameter")
func _start(text : String) -> void:
	var cmd : NativeCommandElement = command
	to = cmd.parse(parser_values)

