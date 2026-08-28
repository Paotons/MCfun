class_name CreateFileWindow
extends ConfirmationDialog
## 创建新文件窗口。

## 创建文件。
signal create_file(path : String)

## 打包场景。
const _PACKED_SCENE := preload("uid://bwfbp4n5l0afb") as PackedScene

## 目录。
@export var directory : String
## 文件扩展名。
@export var file_extension : String
## 如果为 [code]true[/code]，则允许覆盖。
@export var allow_covered := false

static func instantiate() -> void:
	return _PACKED_SCENE.instantiate()

func _ready() -> void:
	canceled.connect(hide)
	confirmed.connect(_on_confirmed)
	close_requested.connect(hide)
	
	_get_line_edit().text_changed.connect(func(_value : String) -> void: test_file())
	test_file()

# 获取编辑框。
func _get_line_edit() -> LineEdit:
	return $MarginContainer/VBoxContainer/LineEdit
# 获取标签。
func _get_lable() -> Label:
	return $MarginContainer/VBoxContainer/Label

## 检查一次，如果有错误，返回 [code]true[/code]。
func test_file() -> bool:
	var label := _get_lable()
	var file := _get_line_edit().text
	
	if not DirAccess.dir_exists_absolute(directory):
		label.set_text("Unvalid directory.")
		label.add_theme_color_override("font_color", Color.RED)
		return true
	
	if file.is_empty():
		label.set_text("Empty filename.")
		label.add_theme_color_override("font_color", Color.RED)
		return true
	
	if not file.is_valid_filename():
		label.set_text("Unvalid filename.")
		label.add_theme_color_override("font_color", Color.RED)
		return true
	
	var path := get_file_path()
	
	if FileAccess.file_exists(path):
		if allow_covered:
			label.set_text("Already exist same-name file, will be coverd.")
			label.add_theme_color_override("font_color", Color.YELLOW)
			return false
		else:
			label.set_text("Already exist same-name filename.")
			label.add_theme_color_override("font_color", Color.RED)
			return true
	elif DirAccess.dir_exists_absolute(path):
		if allow_covered:
			label.set_text("Already exist same-name directory, will be coverd.")
			label.add_theme_color_override("font_color", Color.YELLOW)
			return false
		else:
			label.set_text("Alrady exist same-name directory.")
			label.add_theme_color_override("font_color", Color.RED)
			return true
	
	label.set_text("You can create file!")
	label.add_theme_color_override("font_color", Color.GREEN)
	return false

## 获取路径。
func get_file_path() -> String:
	return directory.path_join(_get_line_edit().text + ("" if file_extension.is_empty() else "." + file_extension))

func _on_confirmed() -> void:
	if not test_file():
		create_file.emit(get_file_path())
		hide()
