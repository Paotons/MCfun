class_name CMDList
extends Resource
## 指令列表。

# 列表类型。
var _list_types : PackedStringArray
# 成员的位置。
var _mumber_columns : PackedInt32Array
# 成员类型。
var _mumber_types : PackedInt32Array
# 成员的值。
var _mumber_values : PackedStringArray

## 返回大小。
func get_size() -> int:
	return _mumber_columns.size()
## 清除所有数据。
func clear() -> void:
	_list_types.clear()
	_mumber_columns.clear()
	_mumber_types.clear()
	_mumber_values.clear()

## 返回指定类型指定位置以前的值。
func get_list(type : String, column := -1) -> PackedStringArray:
	if not _list_types.has(type):
		return PackedStringArray()
	
	var type_id := _list_types.find(type)
	var res : PackedStringArray
	column = 0x7FFFFFFF if column == -1 else column
	for i in get_size():
		var colu := _mumber_columns[i]
		if colu >= column:
			continue
		var id := _mumber_types[i]
		if id != type_id:
			continue
		res.append(_mumber_values[i])
	return res
## 加入新成员。
func add_mumber(type : String, value : String, column := 0) -> void:
	var type_id : int
	if not _list_types.has(type):
		type_id = _list_types.size()
		_list_types.append(type)
	else:
		type_id = _list_types.find(type)
	
	_mumber_types.append(type_id)
	_mumber_columns.append(column)
	_mumber_values.append(value)
## 截断，返回一个新的数据。
func slice(begin : int, end : int) -> CMDList:
	var data := CMDList.new()
	for i in get_size():
		var column := _mumber_columns[i]
		if column >= end or column < begin:
			continue
		data.add_mumber(_get_mumber_type(i), _mumber_values[i], column)
	return data

# 返回成员类型。
func _get_mumber_type(idx : int) -> String:
	return _list_types[_mumber_types[idx]]
