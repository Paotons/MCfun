class_name MCFunExporter
extends Exporter
## mcfun 文件的导出。

## 项目设置。
var setting : ProjectExportSetting

var _command_exporter := CommandExporter.new()
var _help_command_exporter := HelpCommandExporter.new()
var _annotation_command_exporter := AnnotationCommandExporter.new()
var _native_command_exporter := NativeCommandExporter.new()

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
		if command.has_error():
			_add_command_errors(command)
			match setting.do_error_mode:
				ProjectExportSetting.DoErrorMode.IGNORE:
					pass
				ProjectExportSetting.DoErrorMode.DIRECTION:
					to_splited.append(line)
			continue
		
		var string : String
		var exporter : BaseCommandExporter
		
		if command.command_type & CommandElementManager.CommandType.EMPTY != 0:
			if setting.include_empty:
				to_splited.append("")
			continue
		elif command.command_type & CommandElementManager.CommandType.ANNOTATION != 0:
			if setting.include_annotation:
				exporter = _annotation_command_exporter
				exporter.start(line)
				to_splited.append(exporter.get_result())
			continue
		elif command.command_type & CommandElementManager.CommandType.NORMAL != 0:
			exporter = _command_exporter
		elif command.command_type & CommandElementManager.CommandType.HELP != 0:
			exporter = _help_command_exporter
		elif command.command_type & CommandElementManager.CommandType.NATIVE != 0:
			exporter = _native_command_exporter
		exporter.set_command(command)
		exporter.start(line)
		string = exporter.get_result()
		
		if string.is_empty():
			if setting.include_empty:
				to_splited.append("")
		else:
			to_splited.append(string)
	to = "\n".join(to_splited)

func _add_command_errors(command : BaseCommandElement) -> void:
	var text := command.get_valid_string()
	var erros : PackedStringArray
	for err in command.errors:
		erros.append(err.string)
	_add_error("\"%s\" has error:\n%s" % [text, "\n".join(erros)])

func _add_error(error : String) -> void:
	setting.mutex.lock()
	setting.errors.append(error)
	setting.mutex.unlock()
