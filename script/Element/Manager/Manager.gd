@abstract @tool
class_name ElementManager
extends Object
## 元素的管理。
##
## 静态类。

## 结果类型。
enum Type {
	## 错误。
	ERROR = -1,
	#region 没有实际用处，仅作为父类或工具。
	## 空。
	NIL,
	## 参数。
	PARAM,
	## 指令。
	COMMAND,
	#endregion
	
	#region 基本的。
	## 布尔。
	BOOL,
	## 整数。
	INT,
	## 浮点。
	FLOAT,
	## 字符串。
	STRING,
	## 单词。
	WORD,
	#endregion
	
	#region 进阶，但任处于辅助。
	## 指令头。
	HEAD,
	## 选项。
	OPTION,
	## 富文本。
	RICH_STRING,
	## 命名物体。
	SPACEITEM,
	## 点号路径。
	POINT_PATH,
	## 文件路径。
	FILE_PATH,
	## 范围。
	SCOPE,
	## 坐标。
	COORD,
	## 括号。
	BACKET,
	## 等号参数。
	EQUAL_PARAM,
	## 冒号参数。
	COLON_PARAM,
	#endregion
	
	#region 高阶，可支持嵌套方面的。
	## 目标选择器。
	SELECTOR,
	## 多坐标。
	COORDS ,
	## 参数括号。
	PARAM_BACKET,
	## 等号参数括号。
	EQUAL_PARAM_BACKET,
	## 冒号参数括号。
	COLON_PARAM_BACKET,
	## 数组。
	ARRAY,
	#endregion
}

# 变量值 -> 结果值映射表。
const _VALUE_TYPE_TO_Element_MAP : Dictionary[int, int] = {
	GrammarValue.Type.NIL : Type.NIL,
	GrammarValue.Type.COMMAND : Type.COMMAND,
	
	GrammarValue.Type.BOOL : Type.BOOL,
	GrammarValue.Type.INT : Type.INT,
	GrammarValue.Type.FLOAT : Type.FLOAT,
	GrammarValue.Type.STRING : Type.STRING,
	
	GrammarValue.Type.WORD : Type.WORD,
	GrammarValue.Type.SPACEITEM : Type.SPACEITEM,
	GrammarValue.Type.OPTION : Type.OPTION,
	GrammarValue.Type.RICH_STRING : Type.RICH_STRING,
	GrammarValue.Type.POINT_PATH : Type.POINT_PATH,
	GrammarValue.Type.FILE_PATH : Type.FILE_PATH,
	GrammarValue.Type.SCOPE : Type.SCOPE,
	GrammarValue.Type.COORD : Type.COORD,
	
	GrammarValue.Type.SELECTOR : Type.SELECTOR,
	GrammarValue.Type.COORDS : Type.COORDS,
	GrammarValue.Type.QUOTATION : Type.BACKET,
	GrammarValue.Type.DICTIONARY : Type.BACKET,
	GrammarValue.Type.ARRAY : Type.ARRAY,
}
# 固有类型。
const _INHERENT_TYPE : Array[GrammarValue.Type] = [
	GrammarValue.Type.NIL,
	GrammarValue.Type.STRING,
	GrammarValue.Type.RICH_STRING,
	GrammarValue.Type.FILE_PATH,
	GrammarValue.Type.OPTION,
	GrammarValue.Type.COMMAND,
]

## 获取固有类型。[br]
## 固有类型表示不分任何情况，都可能会出现的类型。
static func get_inherent_type() -> Array[GrammarValue.Type]:
	return _INHERENT_TYPE.duplicate()
## 如果指定类型是固有类型，返回 [code]true[/code]。
static func is_inherent_type(type : GrammarValue.Type) -> bool:
	return _INHERENT_TYPE.has(type)
 
## 变量类型转化为元素类型。
static func value_type_to_type(type : int) -> int:
	return _VALUE_TYPE_TO_Element_MAP.get(type, -1)

## 预取其后可能的类型，不包括固有类型。
static func try_get_type(text : String, offset : int) -> Array[GrammarValue.Type]:
	var sult := StringElement.create(text, offset)
	if sult.is_faild:
		return []
	var valid_str := sult.get_valid_string()
	
	match valid_str[0]:
		"@" : return [GrammarValue.Type.SELECTOR]
		"~", "^" : return [GrammarValue.Type.COORDS, GrammarValue.Type.COORD]
		"+", "-" : return [GrammarValue.Type.SCOPE, GrammarValue.Type.FLOAT, GrammarValue.Type.INT, GrammarValue.Type.COORDS, GrammarValue.Type.COORD]
		"{" : return [GrammarValue.Type.DICTIONARY]
		"[" : return [GrammarValue.Type.ARRAY]
		"\"" : return[GrammarValue.Type.QUOTATION]
	
	if valid_str.begins_with(".."):
		return [GrammarValue.Type.SCOPE]
	elif valid_str.ends_with(".."):
		return [GrammarValue.Type.SCOPE]
	elif valid_str.find("..") != -1:
		return [GrammarValue.Type.SCOPE]
	
	if valid_str.find(":") != -1:
		return [GrammarValue.Type.SPACEITEM]
	
	if valid_str.is_valid_int():
		return [GrammarValue.Type.INT, GrammarValue.Type.FLOAT, GrammarValue.Type.COORD, GrammarValue.Type.COORDS, GrammarValue.Type.SCOPE]
	if valid_str.is_valid_float():
		return [GrammarValue.Type.FLOAT, GrammarValue.Type.COORD, GrammarValue.Type.COORDS, GrammarValue.Type.SCOPE]
	
	if StrT.is_letter_char_ord(valid_str.unicode_at(0)):
		return [GrammarValue.Type.WORD, GrammarValue.Type.POINT_PATH, GrammarValue.Type.SELECTOR,GrammarValue.Type.SPACEITEM, GrammarValue.Type.BOOL]
	
	return []

## 通过规则创建。
static func create_from_rule(text : String, offset : int, rule : ElementRule) -> Element:
	var value_type := rule.get_type()
	var element_type := value_type_to_type(value_type)
	var params : Array
	
	match value_type:
		GrammarValue.Type.OPTION, GrammarValue.Type.POINT_PATH, GrammarValue.Type.FILE_PATH, GrammarValue.Type.STRING, GrammarValue.Type.RICH_STRING:
			params = [rule]
		_:
			if GrammarValue.is_type_backet(value_type):
				if rule.has_detail():
					var result_rule := rule.get_rule()
					element_type = BacketElementManager.type_to_element_type(result_rule.get_backet_type())
					params = [GrammarValue.get_type_backet_start(value_type), GrammarValue.get_type_backet_end(value_type), result_rule]
				else:
					params = [GrammarValue.get_type_backet_start(value_type), GrammarValue.get_type_backet_end(value_type)]
	var element := _create_from_params(element_type, text, offset, params)
	return element
# 通过结果调用创建。
static func _create_from_params(type : int, text : String, offset : int, params := []) -> Element:
	assert(type != GrammarValue.Type.ERR, "Is Err.")
	match type:
		Type.NIL, Type.PARAM, Type.COMMAND:
			return null
		Type.INT:
			return IntElement.create(text, offset)
		Type.FLOAT:
			return FloatElement.create(text, offset)
		Type.STRING:
			return StringElement.create(text, offset, params[0])
		
		Type.WORD:
			return WordElement.create(text, offset)
		Type.HEAD:
			return HeadElement.create(text, offset)
		Type.OPTION:
			return OptionElement.create(text, offset, params[0])
		Type.SPACEITEM:
			return SpaceItemElement.create(text, offset)
		Type.RICH_STRING:
			return RichStringElement.create(text, offset)
		Type.POINT_PATH:
			return PointPathElement.create(text, offset, params[0])
		Type.FILE_PATH:
			return FilePathElement.create(text, offset, params[0])
		
		Type.SCOPE:
			return ScopeElement.create(text, offset)
		Type.COORD:
			return CoordElement.create(text, offset)
		Type.BACKET:
			return BacketElement.create(text, offset, params[0], params[1])
		Type.EQUAL_PARAM:
			return EqualParamBacketElement.create(text, offset, params[0], params[1], params[2])
		Type.COLON_PARAM:
			return ColonParamBacketElement.create(text, offset, params[0], params[1], params[2])
		
		Type.SELECTOR:
			return SelectorElement.create(text, offset)
		Type.COORDS:
			return CoordsElement.create(text, offset, params[0])
		Type.PARAM_BACKET:
			return ParamBacketElement.create(text, offset, params[0], params[1], params[2])
		Type.EQUAL_PARAM_BACKET:
			return EqualParamBacketElement.create(text, offset, params[0], params[1], params[2])
		Type.COLON_PARAM_BACKET:
			return ColonParamBacketElement.create(text, offset, params[0], params[1], params[2])
		Type.ARRAY:
			return ArrayBacketElement.create(text, offset, params[0], params[1], params[2])
	breakpoint
	return null

## 通过空位补全数据。
static func get_precast_code_completion_data(type : int, column : int, rule : ElementRule, command : BaseCommandElement) -> CodeCompletionData:
	match type:
		Type.NIL, Type.PARAM, Type.COMMAND:
			return null
		
		Type.BOOL:
			return BoolElement.get_precast_code_completion_data(column, rule, command)
		Type.INT:
			return IntElement.get_precast_code_completion_data(column, rule, command)
		Type.FLOAT:
			return FloatElement.get_precast_code_completion_data(column, rule, command)
		Type.STRING:
			return StringElement.get_precast_code_completion_data(column, rule, command)
		
		Type.WORD:
			return WordElement.get_precast_code_completion_data(column, rule, command)
		Type.HEAD:
			return HeadElement.get_precast_code_completion_data(column, rule, command)
		Type.OPTION:
			return OptionElement.get_precast_code_completion_data(column, rule, command)
		Type.SPACEITEM:
			return SpaceItemElement.get_precast_code_completion_data(column, rule, command)
		Type.RICH_STRING:
			return RichStringElement.get_precast_code_completion_data(column, rule, command)
		Type.POINT_PATH:
			return PointPathElement.get_precast_code_completion_data(column, rule, command)
		Type.FILE_PATH:
			return FilePathElement.get_precast_code_completion_data(column, rule, command)
		Type.FILE_PATH:
			return FilePathElement.get_precast_code_completion_data(column, rule, command)
		Type.SCOPE:
			return ScopeElement.get_precast_code_completion_data(column, rule, command)
		Type.COORD:
			return CoordElement.get_precast_code_completion_data(column, rule, command)
		Type.BACKET:
			return BacketElement.get_precast_code_completion_data(column, rule, command)
		Type.EQUAL_PARAM:
			return EqualParamBacketElement.get_precast_code_completion_data(column, rule, command)
		Type.COLON_PARAM:
			return ColonParamBacketElement.get_precast_code_completion_data(column, rule, command)
		
		Type.SELECTOR:
			return SelectorElement.get_precast_code_completion_data(column, rule, command)
		Type.COORDS:
			return CoordsElement.get_precast_code_completion_data(column, rule, command)
		Type.EQUAL_PARAM_BACKET:
			return EqualParamBacketElement.get_precast_code_completion_data(column, rule, command)
		Type.COLON_PARAM_BACKET:
			return ColonParamBacketElement.get_precast_code_completion_data(column, rule, command)
		Type.ARRAY:
			return ArrayBacketElement.get_precast_code_completion_data(column, rule, command)
		_:
			breakpoint # 正常下不会到这里来
			return null


