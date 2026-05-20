class_name MCFunExporter
extends Exporter
## mcfun 文件的导出。

## 项目设置。
var setting : ProjectExportSetting

func _start(text : String) -> void:
	assert(setting != null, "Not has setting.")
	var text_splited := text.split("\n", setting.include_empty)
	var to_splited : PackedStringArray
	for line in text_splited:
		
		if line.is_empty():
			if setting.include_empty:
				to_splited.append("")
			continue
		
		var command := BaseCommandElement.create(line, 0)
		
		if command.command_type & CommandElementManager.CommandType.EMPTY != 0:
			if setting.include_empty:
				to_splited.append("")
		elif command.command_type & CommandElementManager.CommandType.ANNOTATION != 0:
			if setting.include_annotation:
				var exporter := AnnotationCommandExporter.new()
				exporter.start(line)
				to_splited.append(exporter.get_result())
		elif command.command_type & CommandElementManager.CommandType.NORMAL != 0:
			var exporter := CommandExporter.new()
			exporter.start(line)
			to_splited.append(exporter.get_result())
		elif command.command_type & CommandElementManager.CommandType.HELP != 0:
			var exporter := HelpCommandExporter.new()
			exporter.start(line)
			to_splited.append(exporter.get_result())
	to = "\n".join(to_splited)
