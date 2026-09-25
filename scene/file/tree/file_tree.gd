class_name FileTree
extends Tree
## 文件树。

## 根节点路径。
@export_dir() var root_path : String
## 根节点名称。
@export var root_name : String

## 原地更新树。
func update_tree_item() -> void:
	var folded_directories := get_folded_directories()
	var selected := get_current_selected_path()
	update_tree_from_data(selected, folded_directories)

## 使用数据进行更新。
func update_tree_from_data(selected : String, folded : PackedStringArray) -> void:
	clear()
	
	var root := create_item()
	root.set_text(0, root_name)
	
	var path := root_path
	var queue_directories : Array[DirAccess] = [DirAccess.open(path)]
	var queue_directory_item : Array[TreeItem] = [root]
	
	root.select(0)
	while not queue_directories.is_empty():
		var directory := queue_directories.pop_back() as DirAccess
		var parent := queue_directory_item.pop_back() as TreeItem
		
		for child in directory.get_directories():
			var child_tree := parent.create_child()
			var child_path := directory.get_current_dir().path_join(child)
			
			child_tree.collapsed = folded.has(child_path)
			child_tree.set_text(0, child)
			child_tree.set_custom_color(0, Color.AQUA)
			
			queue_directories.append(DirAccess.open(child_path))
			queue_directory_item.append(child_tree)
			
			if selected == child_path:
				child_tree.select(0)
		
		for child in directory.get_files():
			var child_tree := parent.create_child()
			var child_path := directory.get_current_dir().path_join(child)
			
			child_tree.set_text(0, child)
			if selected == child_path:
				child_tree.select(0)

## 返回当前被折叠的目录。
func get_folded_directories() -> PackedStringArray:
	if get_root() == null:
		return PackedStringArray()
	
	var queue_trees : Array[TreeItem] = [get_root()]
	var queue_paths : Array[String] = [root_path]
	var result : PackedStringArray
	
	while not queue_trees.is_empty():
		var parent := queue_trees.pop_back() as TreeItem
		var parp := queue_paths.pop_back() as String
		
		for i in parent.get_child_count():
			var item := parent.get_child(i)
			var path := parp.path_join(item.get_text(0))
			
			if item.collapsed:
				result.append(path)
			
			queue_trees.append(item)
			queue_paths.append(path)
	return result

## 返回当前选中的文件路径。
func get_current_selected_path() -> String:
	var tree_item := get_selected()
	var paths : PackedStringArray
	
	while tree_item != null:
		paths.append(tree_item.get_text(0))
		tree_item = tree_item.get_parent()
	
	if not paths.is_empty():
		paths.remove_at(paths.size() - 1) # 移除root
	paths.reverse()
	
	return root_path.path_join("/".join(paths))

## 获取该路径下的 TreeItem。
func get_tree_item(path : String) -> TreeItem:
	if path.begins_with(root_path):
		path = path.substr(root_path.length())
	elif path.begins_with(root_name):
		path = path.substr(root_name.length())
	
	var paths := path.substr(root_path.length()).split("/", false)
	var tree_item := get_root()
	for file in paths:
		var flag := false # 包含就是 true
		
		for i in range(tree_item.get_child_count()):
			var child := tree_item.get_child(i)
			if child.get_text(0) == file:
				tree_item = child
				flag = true
				break
		
		if not flag:
			return null
	return tree_item
