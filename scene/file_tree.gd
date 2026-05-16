class_name FileTree
extends Tree
## 文件树。

## 根节点路径。
@export_dir() var root_path : String
## 根节点名称。
@export var root_name : String

## 更新树。
func update_tree_item() -> void:
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
			child_tree.set_text(0, child)
			child_tree.set_custom_color(0, Color.AQUA)
			
			queue_directories.append(DirAccess.open(directory.get_current_dir().path_join(child)))
			queue_directory_item.append(child_tree)
		
		for child in directory.get_files():
			var child_item := parent.create_child()
			child_item.set_text(0, child)

## 获取当前选中的文件路径。
func get_current_selected_path() -> String:
	var tree_item := get_selected()
	var paths : PackedStringArray
	
	while tree_item != null:
		paths.append(tree_item.get_text(0))
		tree_item = tree_item.get_parent()
	
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
