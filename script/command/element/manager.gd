@abstract
class_name CommandElementManager
extends Object
## 指令元素的管理。
##
## 静态类，你不应该实例化。

## 指令类型。
enum CommandType {
	## 空指令。
	EMPTY = 1 << 0,
	## 普通指令。
	NORMAL = 1 << 1,
	## 最开始，根部。
	ROOT = 1 << 2,
	## 直接替代原来的父指令，直达最后，类型于 execute run 分支一样。
	REPLACE = 1 << 3,
	## 以问号开头的指令。
	HELP = 1 << 4,
	## 注释。
	ANNOTATION = 1 << 5,
	## 本地指令。
	NATIVE = 1 << 6,
}
