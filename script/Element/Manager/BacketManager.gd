@abstract @tool
class_name BacketElementManager
extends Object
## 括号管理。
##
## 静态类。

## 括号类别。
enum Type {
	## 普通括号。
	NORMAL,
	## 参数括号。
	PARAM,
	## 等号参数。
	EQUAL_PARAM,
	## 冒号参数。
	COLON_PARAM,
	## 数组。
	ARRAY,
}

# 括号类别转化成结果类型映射表。
const _BACKET_TYPE_TO_ELEMENT_MAP : Dictionary[Type, ElementManager.Type] = {
	Type.NORMAL : ElementManager.Type.BACKET,
	Type.PARAM : ElementManager.Type.PARAM_BACKET,
	Type.EQUAL_PARAM : ElementManager.Type.EQUAL_PARAM_BACKET,
	Type.COLON_PARAM : ElementManager.Type.COLON_PARAM_BACKET,
	Type.ARRAY : ElementManager.Type.ARRAY,
}


## 把括号类别转化成结果类别。
static func type_to_element_type(type : Type) -> ElementManager.Type:
	return _BACKET_TYPE_TO_ELEMENT_MAP.get(type, ElementManager.Type.ERROR)

