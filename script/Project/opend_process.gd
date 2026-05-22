class_name ProjectOpendProcess
extends Resource
## 项目被打开的进度。

enum MainProcessName {
	## 加载缓存。
	CACHE,
	## 进度数量。
	MAX,
}

## 主进度名称。
var main_name : String
## 总进度。
var main_process := Vector2i(-1, -1)
## 分进度/总进度。
var sub_process := Vector2i(-1, -1)
## 锁。
var mutex : Mutex

## 错误。
var errors : PackedStringArray
