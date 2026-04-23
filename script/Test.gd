@tool
extends EditorScript

func _run() -> void:
	var regex := RegEx.create_from_string(r"^\p{P}$")
	print(regex.search("."))
	
