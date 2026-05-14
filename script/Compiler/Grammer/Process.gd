class_name GrammerProcessCompiler
extends GrammerCompiler

func _compile(data : Variant) -> void:
	if not data is Dictionary:
		errors.append("Process_data should be dictionary, but is %s." % type_string(typeof(data)))
		return
	
	var from : Dictionary = data
	
	compiled_result = {}
	if not _test_dictionary_key_types(from, 1 << TYPE_STRING, "Process"):
		return
	if not _test_dictionary_value_types(from, 1 << TYPE_ARRAY, "Process"):
		return
	
	for ele_name : String in from:
		var cmd := from[ele_name] as Array
		if not _test_array_types(cmd, 1 << TYPE_DICTIONARY, "Process[%s]" % ele_name):
			return
		
		compiled_result[ele_name] = []
		(compiled_result[ele_name] as Array).resize(cmd.size())
		
		for i in cmd.size():
			var obj := ExeElementRuleCompiler.new()
			
			obj.element_name = "Process[%s][%d]" % [ele_name, i]
			obj.command = cmd
			
			obj.compile(cmd[i])
			
			_add_error_from_object(obj)
			if not obj.is_valid():
				return
			compiled_result[ele_name][i] = obj.get_result()
	is_faild = false
