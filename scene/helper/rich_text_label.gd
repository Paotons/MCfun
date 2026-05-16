@tool
class_name HelperRichTextLabel
extends RichTextLabel

enum MetaType {
	## 普通。
	NORMAL,
	## 跳转到文件，[get_meta_value] 含有 [code]file[/code]。
	GOTO_FILE,
}

const _GOTO_FILE_COLOR := Color("788bac")

var _title_color : String

func _ready() -> void:
	_title_color = "[left][font_size=24][color=#1562a3]"
	set_helper_text(text)

static var _goto_file_regex := RegEx.create_from_string(r"\[file (?<file>[\p{L}\p{Pc}:./]+)\]")
func set_helper_text(value : String) -> void:
	value = value.replace("[title]", _title_color).replace("[/title]", "[/color][/font_size][/left]").\
		replace("[code]", "[color=#fd4f00]").replace("[/code]", "[/color]")
	var offset := 0
	while true:
		var result := _goto_file_regex.search(value, offset)
		if result == null:
			break
		var file := result.get_string("file")
		value = value.substr(0, result.get_start()) + "[url=**goto file-" + file + "**][color=#788bac]" + file + "[/color][/url]" + value.substr(result.get_end())
		offset = result.get_start() + file.length() + 41 # 字符串增长 41
	set_text(value)

## 返回 [code]url[/code]引起的值。[br]
## 一定含有 [code]type,text[/code]。
func get_meta_value(meta : String) -> Dictionary:
	var l := meta.length()
	if not (meta.begins_with("**") and meta.ends_with("**") and l > 4):
		return {"type" : MetaType.NORMAL, "text" : meta}
	return {"type" : MetaType.GOTO_FILE, "text" : meta.substr(12, l - 14), "file" : meta.substr(12, l - 14) } if meta.begins_with("**goto file-") else \
		{"type" : MetaType.NORMAL, "text" : meta}
