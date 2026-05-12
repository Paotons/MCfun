@abstract @tool
class_name DictionaryIntKeyT
extends Object
## 键为int字典的工具。
##
## 虚函数，这个类不能实例化。

## 截取字典在这个范围内的数据。
static func slice(dict : Dictionary, from : int, to := 0xFFFFFFFF) -> void:
	for key : int in dict.keys():
		if from > key or key >= to:
			dict.erase(key)


