class_name CodeCompletionDataValue
extends Resource

## 插入模式。
var insert_mode := CodeCompletionData.InsertMode.NORMAL
## 如果为 [code]true[/code]，插入后会尝试立即再补全。
var inserted_update := false
## 补全后序列偏移。
var inserted_column_offset := 0

