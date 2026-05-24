class_name AnnotationCommandElementCreater
extends BaseCommandElementCreater
## 注释指令的创建者。

## 从头开始创建。
func run_from_empty(text : String, process : CommandElementCreaterProcess) -> void:
	var offset := StrT.find_unempty(text, process.offset)
	
	if offset == -1:
		command.create_error(process.offset, "Not find any string.")
	elif text[offset] != "#":
		command.create_error(process.offset, "Annotaition must begin with #.")
	command.is_faild = false
	command.valid_start = offset
	
	var highlight := command._highlight_data
	highlight.merge({offset : {"color" : process.edit.color_annotation}, text.length() : {"color" : process.edit.color_default}})
