class_name GrammerPathChapter
extends GrammerChapter

var main_data : Dictionary

enum _PathMeta {
	# 表示可直接结尾。
	IS_END,
	# 表示直接结尾的成员。
	MUMBER,
	# 表示成员的分组。
	GROUP_MUMBER,
	# 分组数据。
	GROUP_DATA,
}

func _get_type() -> ChapterType:
	return ChapterType.PATH

func _set_data(data : Dictionary) -> void:
	main_data = data[ChapterMeta.DATA]

## 获取所有路径。
func get_paths(path : PackedStringArray = []) -> Array[PackedStringArray]:
	var data := main_data
	for branch in path:
		if _has_branch(data, branch):
			data = _get_branch_data(data, branch)
		else:
			return []
	return _get_paths(data, path)
## 如果有该路径，返回 [code]true[/code]。
func has_path(path : PackedStringArray) -> bool:
	var data := main_data
	for branch in path:
		if _has_branch(data, branch):
			data = _get_branch_data(data, branch)
		else:
			return false
	return true
## 获取下一步的所有分支。
func get_branchs(path : PackedStringArray) -> PackedStringArray:
	var data := _get_path_data(main_data, path)
	if data.is_empty():
		return []
	return _get_branchs(data)

# 获取路径的数据。
static func _get_path_data(data : Dictionary, path : PackedStringArray) -> Dictionary:
	for branch in path:
		data = _get_branch_data(data, branch)
		if data.is_empty():
			return {}
	return data
# 获取下一步的所有分支。
static func _get_branchs(data : Dictionary) -> PackedStringArray:
	var res : PackedStringArray
	if data[_PathMeta.IS_END]:
		res.append("")
	res.append_array(data[_PathMeta.MUMBER])
	res.append_array(data[_PathMeta.GROUP_MUMBER])
	return res
# 下一步分支如果有该分支，返回 true。
static func _has_branch(data : Dictionary, branch : String) -> bool:
	if data.is_empty():
		return false
	if branch.is_empty():
		return data[_PathMeta.IS_END]
	return data[_PathMeta.MUMBER].has(branch) or data[_PathMeta.GROUP_MUMBER].has(branch)
# 获取数据下一步的分支数据。
static func _get_branch_data(data : Dictionary, branch : String) -> Dictionary:
	var group := data[_PathMeta.GROUP_MUMBER] as PackedStringArray
	if group.has(branch):
		var idx := group.find(branch)
		return data[_PathMeta.GROUP_DATA][idx]
	return {}
# 获取这个数据和这个路径下的全部路径。
static func _get_paths(data : Dictionary, path := PackedStringArray()) -> Array[PackedStringArray]:
	if data.is_empty(): return []
	var res : Array[PackedStringArray]
	
	if (data[_PathMeta.IS_END] as bool) == true:
		res.append(path.duplicate())
	if not (data[_PathMeta.MUMBER] as PackedStringArray).is_empty():
		for mumber in data[_PathMeta.MUMBER] as PackedStringArray:
			res.append(path + PackedStringArray([mumber]))
	if not (data[_PathMeta.GROUP_MUMBER] as PackedStringArray).is_empty():
		var mumbers := data[_PathMeta.GROUP_MUMBER] as PackedStringArray
		var datas := data[_PathMeta.GROUP_DATA] as Array[Dictionary]
		for i in mumbers.size():
			res.append_array(_get_paths(datas[i], path + PackedStringArray([mumbers[i]])))
	return res

## 解析。
static func compile(from : Dictionary, to : Dictionary) -> bool:
	if _compile_data(from, to): return true
	return true

# 解析数据。
static func _compile_data(from : Dictionary, to : Dictionary) -> bool:
	if not from.has("data"):
		push_error("Not has meta \"data\".")
		return true
	var data = from["data"]
	if data is Dictionary:
		var to_data : Dictionary
		if _compile_path(data, to_data): return true
		to[ChapterMeta.DATA] = to_data
		return false
	else:
		push_error("Meta \"data\" should be dictionary, but is \"%s\"." % [type_string(typeof(data))])
		return true

static func _compile_path(from : Dictionary, to : Dictionary) -> bool:
	if from.has(""):
		to[_PathMeta.IS_END] = true
		from.erase("")
	else:
		to[_PathMeta.IS_END] = false
	
	var mumber : PackedStringArray
	var group_mumber : PackedStringArray
	var group_data : Array[Dictionary]
	for key in from:
		if not key is String:
			push_error("Meta \"data-path\" should be dictionary, but is \"%s\"." % [type_string(typeof(key))])
			return true
		var value = from[key]
		if value is bool:
			mumber.append(key)
		elif value is Dictionary:
			group_mumber.append(key)
			var result : Dictionary
			if _compile_path(value, result):
				return true
			group_data.append(result)
		else:
			push_error("Meta \"data-value\" should be dictionary or bool, but is \"%s\"." % [type_string(typeof(key))])
			return true
	to[_PathMeta.MUMBER] = mumber
	to[_PathMeta.GROUP_MUMBER] = group_mumber
	to[_PathMeta.GROUP_DATA] = group_data
	return false

