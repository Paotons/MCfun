class_name GrammarProcessCompiler
extends GrammarCompiler

## 进程名称。
var process_name := "Process"

const _COMMAND_DESCRIPTION := 0
const _COMMAND_DATA := 1

enum ProcessMeta {
	## 描述。
	DESCRIPTION,
	## 数据。
	DATA,
	## 元列表类型。
	CMD_LIST_TYPES,
}

class _CommandData extends GrammarCompiler:
	var command_name : String
	var cmd_list_types : PackedStringArray
	func _compile(data : Variant) -> void:
		if not _test_value_type(data, 1 << TYPE_ARRAY, command_name):
			return
		
		var from : Array = data
		if not _test_array_types(from, 1 << TYPE_DICTIONARY, command_name):
			return
		
		compiled_result = []
		(compiled_result as Array).resize(from.size())
		
		for i in from.size():
			var obj := ExeElementRuleCompiler.new()
			obj.element_name = "%s[%d]" % [command_name, i]
			obj.command = from
			
			obj.compile(from[i])
			
			_add_error_from_object(obj)
			if not obj.is_valid():
				return
			cmd_list_types.append_array(obj.cmd_list_types)
			compiled_result[i] = obj.get_result()
		_set_is_valid(true)


func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("%s_data should be dictionary, but is %s." % [process_name, type_string(typeof(data))])
		return
	
	var from : Dictionary = data
	
	compiled_result = {}
	compiled_result[ProcessMeta.CMD_LIST_TYPES] = PackedStringArray()
	compiled_result[ProcessMeta.DATA] = {}
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, process_name):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_ARRAY | 1 << TYPE_DICTIONARY, process_name):
		return
	
	for key : String in from:
		var value = from[key]
		if value is Array:
			if not _compile_v1(key, value):
				return
		elif value is Dictionary:
			if not _compile_v2(key, value):
				return
	
	_set_is_valid(true)

func _compile_v1(key : String, from : Array) -> bool:
	compiled_result[ProcessMeta.DATA][key] = {}
	compiled_result[ProcessMeta.DATA][key][_COMMAND_DESCRIPTION] = ""
	
	var obj := _CommandData.new()
	obj.command_name = "%s[%s]" % [process_name, key]
	obj.process_data = compiled_result
	
	obj.compile(from)
	
	_add_error_from_object(obj)
	if not obj.is_valid():
		return false
	
	_append_cmd_list_types(obj.cmd_list_types)
	compiled_result[ProcessMeta.DATA][key][_COMMAND_DATA] = obj.get_result()
	return true

func _compile_v2(key : String, from : Dictionary) -> bool:
	const _DESCRIPTION_KEY := "description"
	const _DATA_KEY := "data"
	compiled_result[ProcessMeta.DATA][key] = {}
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "%s[%s]" % [process_name, key]):
		return false
	
	compiled_result[ProcessMeta.DATA][key][_COMMAND_DESCRIPTION] = from[_DESCRIPTION_KEY] if from.has(_DESCRIPTION_KEY) and from[_DESCRIPTION_KEY] is String else ""
	
	if not from.has(_DATA_KEY):
		errors.append("%s[%s] not has data." % [process_name, key])
		return false
	if not _test_value_type(from[_DATA_KEY], 1 << TYPE_ARRAY, "%s[%s][data]" % [process_name, key]):
		return false
	
	var obj := _CommandData.new()
	obj.command_name = "%s[%s][data]" % [process_name, key]
	
	obj.compile(from[_DATA_KEY])
	_add_error_from_object(obj)
	if not obj.is_valid():
		return false
	
	if not obj.cmd_list_types.is_empty():
		_append_cmd_list_types(obj.cmd_list_types)
	compiled_result[ProcessMeta.DATA][key][_COMMAND_DATA] = obj.get_result()
	return true

# 加入指令列表。
func _append_cmd_list_types(types : PackedStringArray) -> void:
	var cmd_list_types : PackedStringArray = compiled_result[ProcessMeta.CMD_LIST_TYPES]
	cmd_list_types.append_array(types)

