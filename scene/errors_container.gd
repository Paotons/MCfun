class_name ErrorListContainer
extends VBoxContainer
## 显示错误列表容器。

## 跳转。
signal goto(line : int, column : int)

## 跳转文本的颜色。
@export var goto_text_color := Color(0.899, 0.16, 0.0, 1.0)

class _ErrorContainer extends HBoxContainer:
	const _GOTO_TEXT_MODEL := "第%d行第%d列："
	
	## 跳转按钮被按下.
	signal goto_pressed(line : int, column : int)
	
	var goto_button := Button.new()
	var hint_label := Label.new()
	var error_position : Vector2i
	
	func _init_tree() -> void:
		goto_button.flat = true
		goto_button.pressed.connect(_on_goto_button_pressed)
		add_child(goto_button, false, Node.INTERNAL_MODE_BACK)
		add_child(hint_label, false, Node.INTERNAL_MODE_BACK)
	
	func _on_goto_button_pressed() -> void:
		goto_pressed.emit(error_position.y, error_position.x)
	
	## 创建一个新容器。
	static func create(line : int, error : ElementError, goto_label_color : Color) -> _ErrorContainer:
		var node := _ErrorContainer.new()
		node._init_tree()
		node.goto_button.add_theme_color_override(&"font_color", goto_label_color)
		node.goto_button.add_theme_color_override(&"font_focus_color", goto_label_color)
		node.goto_button.add_theme_color_override(&"font_hover_color", goto_label_color)
		node.goto_button.add_theme_color_override(&"font_hover_pressed_color", goto_label_color)
		node.goto_button.set_text(_GOTO_TEXT_MODEL % [line + 1, error.column])
		node.hint_label.set_text(error.string)
		node.error_position = Vector2i(error.column, line)
		return node

## 添加一个错误。
func add_error(line : int, error : ElementError) -> void:
	var container := _ErrorContainer.create(line, error, goto_text_color)
	container.goto_pressed.connect(_on_child_goto_pressed)
	add_child(container)
## 清空所有错误。
func clear() -> void:
	for child in get_children():
		child.queue_free()

func _on_child_goto_pressed(line : int, column : int) -> void:
	goto.emit(line, column)
