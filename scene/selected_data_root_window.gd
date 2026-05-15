class_name SelectedDataRootWindow
extends AcceptDialog

func _on_confirmed() -> void:
	FileSystem.set_data_root_path(_get_root_path())
	close_requested.emit()

func _get_root_path() -> String:
	return $MarginContainer/VBoxContainer/HBoxContainer/Path.text
