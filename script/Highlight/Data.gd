class_name HightLightData
extends Resource

## 数据。
var data : Dictionary[int, Dictionary]

## 添加高亮。
func add(idx : int, color : Color) -> void:
	data[idx] = {"color" : color}
## 覆盖数据。
func merge(value : Dictionary[int, Dictionary], over := true) -> void:
	data.merge(value, over)
## 移动。
func move(offset : int) -> void:
	var to : Dictionary[int, Dictionary]
	for key in data.keys():
		to[key - offset] = data[key]
	data = to

