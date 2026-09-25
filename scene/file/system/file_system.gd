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

## 实例化。
func instantiate() -> FileSystemWindow:
	return _PACKED_SCENE.instantiate()
