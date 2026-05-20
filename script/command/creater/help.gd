class_name HelpCommandElementCreater
extends BaseCommandElementCreater
## 帮助指令的创建者。

# 解析正则表达式。
static var _help_command_regex := RegEx.create_from_string(r"^ *(?<head>\?|help) *(?<child>[\p{L}\p{Pc}0-9_]+)?")

func get_command() -> HelpCommandElement:
	return command

# 偷个懒，就不用 element 了。
func run_from_empty(text : String, process : CommandElementCreaterProcess) -> void:
	var offset := process.offset
	var string := text.substr(offset)
	get_command().string = string
	get_command().string_offset = offset
	
	var result := _help_command_regex.search(string, 0)
	if result == null:
		get_command().create_error(offset, "Not has help.")
		return
	get_command().is_faild = false
	
	if result.get_start() != 0:
		command.create_error(offset, "Unvaild beginning.")
	
	var highlight := get_command()._highlight_data
	highlight.merge({result.get_start("head") + offset : {"color" : process.edit.color_key_word}, result.get_end("head") + offset : {"color" : process.edit.color_default}})
	if result.get_start("child") != -1:
		highlight.merge({result.get_start("child") + offset : {"color" : process.edit.color_option}, result.get_end("child") + offset : {"color" : process.edit.color_default}})
