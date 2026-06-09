@tool
extends EditorScript
## 用于测试的脚本。


func _run() -> void:
	for i : String in ["从前有座山", "山里有座庙", "庙里有个老和尚给小和尚讲故事", "讲的是什么呢"]:
		var a := i.to_utf8_buffer()
		print(Marshalls.raw_to_base64(a))
