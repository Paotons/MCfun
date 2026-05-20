class_name ProjectExportSetting
extends Resource
## 项目导出设置。

## 主要进度。
enum MainProcess {
	## 开始。
	START,
	## 创建 mainfest 文件。
	MANIFEST,
	## 解析 functons。
	FUNCTIONS,
	## 总进度。
	MAX,
}

## 路径。
var path : String
## 如果为 [code]true[/code]，则保留注释。
var include_annotation := false
## 如果为 [code]true[/code]，则保留空行。
var include_empty := false

## 锁，线程运行修改当前进度时用的锁。
var mutex : Mutex
## 主要进度。
var main_process : int
## 当前进度。
var current_process : String
## 分进度，[param x]为当前进度，[param y]为分总进度。
var sub_process : Vector2i
