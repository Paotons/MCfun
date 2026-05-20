class_name AnnotationCommandExporter
extends Exporter
## 普通指令的导出。


func _start(text : String) -> void:
	# 移动到头。
	var offset := StrT.find_unempty(text, 0)
	to = text.substr(offset)
