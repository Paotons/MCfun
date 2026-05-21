@tool
class_name HelperRichTextLabel
extends RichTextLabel
## 用于显示 help 的富文本。
# 我承认我很懒，懒得重写富文本。用个 Meta 将就将就。

enum MetaType {
	## 普通。
	NORMAL,
	## 跳转到文件，[get_meta_value] 含有 [code]file[/code]。
	GOTO_FILE,
	## 跳转到网站，[get_meta_value] 含有 [code]http[/code]。
	GOTO_HTTP,
}

const _GOTO_FILE_COLOR := Color("788bac")
const _GOTO_HTTP_COLOR := Color("5391ff")

var _title_color : String

func _ready() -> void:
	_title_color = "[left][font_size=24][color=#1562a3]"
	set_helper_text(text)

static var _meta_regex := RegEx.create_from_string(r"\[(?<head>file|http) (?<value>[\p{L}\p{Pc}:./]+)\]")
func set_helper_text(value : String) -> void:
	value = value.replace("[title]", _title_color).replace("[/title]", "[/color][/font_size][/left]").\
		replace("[/file]", "[/color][/url]").replace("[/http]", "[/color][/url]").\
		replace("[code]", "[color=#fd4f00]").replace("[/code]", "[/color]")
	var offset := 0
	while true:
		var result := _meta_regex.search(value, offset)
		if result == null:
			break
		var head := result.get_string("head")
		var val := result.get_string("value")
		match head:
			"file":
				value = value.substr(0, result.get_start()) + "[url=**goto file-" + val + "**][color=#788bac]" + value.substr(result.get_end())
			"http":
				value = value.substr(0, result.get_start()) + "[url=**goto http-" + val + "**][color=#5391ff]" + value.substr(result.get_end())
			_:
				push_error("Error meta head %s." % head)
		offset = result.get_start() + val.length() + 13 # "url=**goto **" 增长
	set_text(value)

## 返回 [code]url[/code]引起的值。[br]
## 一定含有 [code]type,text[/code]。
func get_meta_value(meta : String) -> Dictionary:
	var l := meta.length()
	if not (meta.begins_with("**") and meta.ends_with("**") and l > 4):
		return {"type" : MetaType.NORMAL, "text" : meta}
	if meta.begins_with("**goto file-") :
		return {"type" : MetaType.GOTO_FILE, "text" : meta.substr(12, l - 14), "file" : meta.substr(12, l - 14) }
	elif meta.begins_with("**goto http-") :
		return {"type" : MetaType.GOTO_HTTP, "text" : meta.substr(12, l - 14), "http" : meta.substr(12, l - 14) }
	else:
		return {"type" : MetaType.NORMAL, "text" : meta}
