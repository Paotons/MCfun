@tool
extends EditorScript

func _run() -> void:
	var control := EditorInterface.get_base_control()
	var tree := control.get_tree_string_pretty()
	print(tree.count("\n"))
