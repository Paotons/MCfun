class_name FileSystemWindow
extends Window
## 文件系统窗口。

@warning_ignore("unused_signal")
## 打开文件。
signal file_open(path : String)
## 批量打开文件。
@warning_ignore("unused_signal")
signal multifile_open(path : PackedStringArray)

# 创场景。
const _PACKED_SCENE := preload("res://scene/FileSystem.tscn")

## 实例化。
func instantiate() -> FileSystemWindow:
	return _PACKED_SCENE.instantiate()
