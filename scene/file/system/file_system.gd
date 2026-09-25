class_name FileSystemWindow
extends Window
## 文件系统窗口。
# 想做复制和移动那些功能的，费力，算了。

@warning_ignore("unused_signal")
## 打开文件。
signal file_open(path : String)
## 批量打开文件。
@warning_ignore("unused_signal")
signal multifile_open(path : PackedStringArray)
## 删除文件/目录。
@warning_ignore("unused_signal")
signal removed_directory(path : String)
## 移动/重命名 文件/目录。
@warning_ignore("unused_signal")
signal renamed_file(path : String, to_path : String)
## 复制路径。
@warning_ignore("unused_signal")
signal copyed_file(path : String, to_path : String)

# 创场景。
const _PACKED_SCENE := preload("uid://b1mh5o58v8e5g")

## 必要的节点。
@export var essent_nodes : Dictionary[StringName, Node]

## 实例化。
func instantiate() -> FileSystemWindow:
	return _PACKED_SCENE.instantiate()

func _get_file_tree() -> FileTree:
	return essent_nodes.get(&"FileTree")

## 保存窗口数据到配置文件。
func save_to_config(config : ConfigFile) -> void:
	const SELECTOR := "FileSystem"
	
	var tree := _get_file_tree()
	config.set_value(SELECTOR, "folded_directories", tree.get_folded_directories())
	config.set_value(SELECTOR, "selected", tree.get_current_selected_path())

## 配置文件为指定文件。
func config_window(config : ConfigFile) -> void:
	const SELECTOR := "FileSystem"
	
	var folded_directories := config.get_value(SELECTOR, "folded_directories", PackedStringArray()) as PackedStringArray
	var selected := config.get_value(SELECTOR, "selected", "") as String
	
	var tree := _get_file_tree()
	tree.update_tree_from_data(selected, folded_directories)
