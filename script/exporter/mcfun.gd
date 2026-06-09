class_name MCFunExporter
extends Exporter
## mcfun 文件的导出。

## 项目设置。
var setting : ProjectExportSetting

var _command_exporter := CommandExporter.new()
var _help_command_exporter := HelpCommandExporter.new()
var _annotation_command_exporter := AnnotationCommandExporter.new()
var _native_command_exporter := NativeCommandExporter.new()

#region start
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
		
		if command.command_type & CommandElementManager.CommandType.EMPTY != 0: _start_empty(to_splited)
		elif command.command_type & CommandElementManager.CommandType.ANNOTATION != 0: _start_annotation(line, to_splited)
		elif command.command_type & CommandElementManager.CommandType.COMMENT != 0: continue
		elif command.command_type & CommandElementManager.CommandType.NORMAL != 0: _start_normal(line, command, to_splited)
		elif command.command_type & CommandElementManager.CommandType.HELP != 0: _start_help(line, command, to_splited)
		elif command.command_type & CommandElementManager.CommandType.NATIVE != 0: _start_native(line, command, to_splited)
		else: push_error("Unvaild command_type %d." % command.command_type)
	to = "\n".join(to_splited)

func _start_empty(to_splited : PackedStringArray) -> void:
	if setting.include_empty:
		to_splited.append("")

func _start_annotation(line : String, to_splited : PackedStringArray) -> void:
	if setting.include_annotation:
		var exporter := _annotation_command_exporter
		exporter.start(line)
		to_splited.append(exporter.get_result())

func _start_normal(line : String, command : CommandElement, to_splited : PackedStringArray) -> void:
	if command.has_error():
		_add_command_errors(command)
		match setting.do_error_mode:
			ProjectExportSetting.DoErrorMode.IGNORE: pass
			ProjectExportSetting.DoErrorMode.DIRECTION: to_splited.append(line)
		return
	var exporter := _command_exporter
	exporter.set_command(command)
	exporter.start(line)
	_append_string(exporter.get_result(), to_splited)

func _start_help(line : String, command : HelpCommandElement, to_splited : PackedStringArray) -> void:
	if command.has_error():
		_add_command_errors(command)
		match setting.do_error_mode:
			ProjectExportSetting.DoErrorMode.IGNORE: pass
			ProjectExportSetting.DoErrorMode.DIRECTION: to_splited.append(line)
		return
	var exporter := _help_command_exporter
	exporter.set_command(command)
	exporter.start(line)
	_append_string(exporter.get_result(), to_splited)

func _start_native(line : String, command : NativeCommandElement, to_splited : PackedStringArray) -> void:
	var exporter := _native_command_exporter
	exporter.set_command(command)
	exporter.start(line)
	var string := exporter.get_result()
	
	if string.is_empty() and command.has_error():
		_add_command_errors(command)
		match setting.do_error_mode:
			ProjectExportSetting.DoErrorMode.IGNORE: pass
			ProjectExportSetting.DoErrorMode.DIRECTION: to_splited.append(line)
		return
	
	_append_string(string, to_splited)
#endregion

func _append_string(string : String, splited : PackedStringArray) -> void:
	if string.is_empty():
		if setting.include_empty:
			splited.append("")
	else:
		splited.append(string)

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
