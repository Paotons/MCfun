class_name CommandElementCreaterProcess
extends Resource
## 创建指令元素的进度。

## 偏移。
var offset : int
## 行数。
var line : int

## 指令规则。
var rule : CommandRule

## 当前执行元素。
var exe_element : ExeElementRule
## 执行序列。
var exe_index : int
## 最大执行序列。
var exe_end : int

## 可结束标志。
var has_end := false

## 退出标志。
var break_flag := false
## 继续标志。
var continue_flag := false

## 编辑器。
var edit : FunctionEdit
## 语法。
var grammar : GrammarProcess
## 规则。
var law : GrammarLaw
## 字符串。
var entry : GrammarEntry
