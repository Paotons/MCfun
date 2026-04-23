class_name GDScriptClass
extends RefCounted
## 类码。
##
## 对于原版类码局限性的包装。[br][br]
## 以下是对引擎类码的介绍。
## [codeblock]
## var class_code := Object # 我是类码
## print((class_code as Object).get_class()) # 输出 GDScriptNativeClass 如果是用户类将输出 GDScript
## # obj : GDScriptNativeClass 原版中这种是不允许的
## # obj : Object 原版支持，但无法保证这是类码
## [/codeblock]

# 类码。
var _class_code := Object
# 名称。
var _class_name : String

## 返回类码。
func get_class_code() -> Object:
	return _class_code
## 获取类名。[br][br]
## [b]注意：[/b] 如果类码对应的类创建开销或者是销毁开销较大，可能产生性能负担。
func get_class_name() -> String:
	if not _class_name.is_empty():
		return _class_name
	# 没招，类码必须要实例了才能获取到实例后的值。
	var obj := _class_code.new()
	if obj is RefCounted:
		return obj.get_class()
	else:
		var class_code := obj.get_class()
		obj.free()
		return class_code

## 立即创建一个。
static func create(class_code : Object, name := "") -> GDScriptClass:
	var a := GDScriptClass.new()
	a.set_native_class(class_code, name)
	return a
## 设置类码。如果不是引擎内部类型，建议 [param name] 不要空着，使用 [method get_class_name] 将优先作为值返回。
func set_class(class_code : Object, name := "") -> void:
	assert(class_code.get_class() == "GDScriptNativeClass" or class_code.get_class() == "GDScript", "Clas is unvalid.")
	_class_code = class_code
	_class_name = name
## 实例化。
func instance(params := []) -> Object:
	return _class_code.new() if params.is_empty() else _class_code.new.callv(params)
