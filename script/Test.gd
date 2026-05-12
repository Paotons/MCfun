@tool
extends EditorScript
## 用于测试的脚本。

func _run() -> void:
	var output := []
	OS.execute("cd script", [])
	OS.execute("ls", [], output)
	print(output)
