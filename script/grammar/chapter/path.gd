class_name GrammarPathChapter
extends GrammarChapter

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

## 获取指定路径下所有的子路径。
func get_paths(path : PackedStringArray = []) -> Array[PackedStringArray]:
	var tree := _get_path_tree(main_data, path)
	if tree.is_empty():
		return []
	return _get_paths(tree, path)
## 获取指定路径下子路径的数量。
func get_paths_count(path : PackedStringArray = []) -> int:
	var tree := _get_path_tree(main_data, path)
	if tree.is_empty():
		return 0
	return _get_paths_count(tree)
## 如果有该路径，返回 [code]true[/code]。
func has_path(path : PackedStringArray) -> bool:
	var tree := main_data
	for branch in path:
		if _has_branch(tree, branch):
			tree = _get_branch_tree(tree, branch)
		else:
			return false
	return true
## 获取指定路径下所有的分支。
func get_branchs(path : PackedStringArray) -> PackedStringArray:
	var tree := _get_path_tree(main_data, path)
	if tree.is_empty():
		return []
	return _get_branchs(tree)
## 获取指定路径下分支的数量。
func get_branch_count(path : PackedStringArray) -> int:
	var tree := _get_path_tree(main_data, path)
	if tree.is_empty():
		return 0
	return _get_branchs_count(tree)
## 如果这个路径可结束，返回 [code]true[/code]。
func is_path_end(path : PackedStringArray) -> bool:
	if path.is_empty():
		return false
	var parent := _get_path_tree(main_data, _get_path_parent(path))
	if parent.is_empty():
		return false
	return _is_branch_end(parent, path[-1])

# 获取路径
# 获取路径的上一级。
static func _get_path_parent(path : PackedStringArray) -> PackedStringArray:
	return path.slice(0, path.size() - 1)
# 获取树中下一个分支的树。
static func _get_branch_tree(tree : Dictionary, branch : String) -> Dictionary:
	var group := tree[_PathMeta.GROUP_MUMBER] as PackedStringArray
	if group.has(branch):
		var idx := group.find(branch)
		return tree[_PathMeta.GROUP_DATA][idx]
	return {}
# 获取树中指定路径下的分支树。
static func _get_path_tree(tree : Dictionary, path : PackedStringArray) -> Dictionary:
	for branch in path:
		tree = _get_branch_tree(tree, branch)
		if tree.is_empty():
			return {}
	return tree
# 如果树中指定分支可结束，返回 true。
static func _is_branch_end(tree : Dictionary, branch : String) -> bool:
	if branch == "":
		return tree[_PathMeta.IS_END]
	return (tree[_PathMeta.MUMBER] as Array).has(branch)

# 获取指定树下的所有分支。
static func _get_branchs(tree : Dictionary) -> PackedStringArray:
	var res : PackedStringArray
	if tree[_PathMeta.IS_END]:
		res.append("")
	res.append_array(tree[_PathMeta.MUMBER])
	res.append_array(tree[_PathMeta.GROUP_MUMBER])
	return res
# 获取指定数据下分支的数量。
static func _get_branchs_count(tree : Dictionary) -> int:
	var res := 0
	res += (tree[_PathMeta.MUMBER] as Array).size()
	res += (tree[_PathMeta.GROUP_MUMBER] as Array).size()
	return res
# 如果树中有指定分支，返回 true。
static func _has_branch(tree : Dictionary, branch : String) -> bool:
	if tree.is_empty():
		return false
	if branch.is_empty():
		return tree[_PathMeta.IS_END]
	return tree[_PathMeta.MUMBER].has(branch) or tree[_PathMeta.GROUP_MUMBER].has(branch)
# 获取这个树指定路径下的全部路径。
static func _get_paths(tree : Dictionary, path := PackedStringArray()) -> Array[PackedStringArray]:
	if tree.is_empty(): return []
	var res : Array[PackedStringArray]
	
	if (tree[_PathMeta.IS_END] as bool) == true:
		res.append(path.duplicate())
	if not (tree[_PathMeta.MUMBER] as PackedStringArray).is_empty():
		for mumber in tree[_PathMeta.MUMBER] as PackedStringArray:
			res.append(path + PackedStringArray([mumber]))
	if not (tree[_PathMeta.GROUP_MUMBER] as PackedStringArray).is_empty():
		var mumbers := tree[_PathMeta.GROUP_MUMBER] as PackedStringArray
		var trees := tree[_PathMeta.GROUP_DATA] as Array[Dictionary]
		for i in mumbers.size():
			res.append_array(_get_paths(trees[i], path + PackedStringArray([mumbers[i]])))
	return res
# 获取树下所有的路径数量。
static func _get_paths_count(tree : Dictionary) -> int:
	var res := 0
	
	var queue_tree : Array[Dictionary] = [tree]
	while not queue_tree.is_empty():
		tree = queue_tree.pop_back()
		
		if queue_tree[_PathMeta.IS_END]:
			res += 1
		
		res += (tree[_PathMeta.MUMBER] as Array).size()
		res += (tree[_PathMeta.GROUP_MUMBER] as Array).size()
		queue_tree.append_array(tree[_PathMeta.GROUP_DATA])
	
	return res
