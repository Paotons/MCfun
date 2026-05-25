class_name NativeCommandElementParser
extends RefCounted
## 解析本地指令。
## 
##
# 别管，反正就是死代码，恶心得要死。

## 变量的数据。
var value_datas : NativeCommandElementParserValues
## 指令。
var commamd : NativeCommandElement

## 开始解析。
func parse() -> String:
	if commamd.has_error():
		return ""
	
	match commamd.get_head_string():
		"string": return _parse_string()
		"tp": return _parse_tp()
	
	return ""

func _parse_string() -> String:
	var element : StringElement = commamd.get_element(0)
	return element.get_valid_string()

func _parse_tp() -> String:
	const MODE_OPTION_INDEX := 1
	
	const SCORE_MODE := 0
	
	var mode := (commamd.get_element(MODE_OPTION_INDEX) as OptionElement).get_option_index()
	match mode:
		SCORE_MODE: return _parse_tp_score()
		_: return ""

#region tp score
# &tp selector score coord score_selector scoreboard mode
func _parse_tp_score() -> String:
	const SELECT_INDEX := 0
	const COORD_INDEX := 2
	const SCORE_SELECT_INDEX := 3
	const SCORE_INDEX := 4
	const MODE_INDEX := 5
	const SCALE_INDEX := 6
	const ITER_INDEX := 7
	
	const TO_MODE := 0
	@warning_ignore("unused_local_constant")
	const OFFSET_MODE := 1
	
	const DEFAULT_ITER := 26 # 因为 1 << 25 == 3300w MC地图最大 3000w
	var count := commamd.get_element_count()
	
	var target := (commamd.get_element(SELECT_INDEX) as SelectorElement).get_valid_string()
	var coord := (commamd.get_element(COORD_INDEX) as OptionElement).get_valid_string()
	var scorer := (commamd.get_element(SCORE_SELECT_INDEX) as SelectorElement).get_valid_string()
	var board := (commamd.get_element(SCORE_INDEX) as WordElement).get_valid_string()
	var mode := (commamd.get_element(MODE_INDEX) as OptionElement).get_option_index() if MODE_INDEX < count - 2 else 0
	var scale := (commamd.get_element(SCALE_INDEX) as FloatElement).get_value() if SCALE_INDEX < count - 2 else 1.0
	var iter := (commamd.get_element(ITER_INDEX) as IntElement).get_value() if ITER_INDEX < count - 2 else DEFAULT_ITER
	var coords : Array[bool] = [coord.find("x") != -1, coord.find("y") != -1, coord.find("z") != -1]
	return _parse_tp_score_do(target, scorer, board, coords, mode == TO_MODE, scale, iter)

func _parse_tp_score_do(target : String, scorer : String, board : String, coords : Array[bool], is_to : bool, scale : float, iter : int) -> String:
	var res : PackedStringArray
	
	var target_tag := "_temp_" + StrT.rand_base63(16)
	var tag_target := "@e[tag=%s]" % target_tag
	res.append("tag %s add %s" % [target, target_tag])
	
	var tag_scorer := "_temp_" + StrT.rand_base63(16)
	res.append("scoreboard players operation %s %s = %s %s" % [tag_scorer, board, scorer, board])
	
	if is_to:
		res.append("tp %s %s %s %s" % [tag_target, "0" if coords[0] else "~", "0" if coords[1] else "~", "0" if coords[2] else "~"])
	
	res.append_array(_parse_tp_score_tp(tag_target, tag_scorer, board, coords, scale, iter))
	
	res.append("tag %s remove %s" % [tag_target, target_tag])
	res.append("scoreboard players reset %s %s" % [tag_scorer, board])
	
	return "\n".join(res)

func _parse_tp_score_tp(target : String, scorer : String, board : String, coords : Array[bool], scale : float, iter : int) -> PackedStringArray:
	const MODEL := "execute if score %s %s matches %s..%s as %s at @s run tp @s %s\nexecute if score %s %s matches %s..%s run scoreboard players add %s %s %d"
	
	var res : PackedStringArray
	var coords_model := " ".join(PackedStringArray(["~%f" if coords[0] else "~", "~%f" if coords[1] else "~", "~%f" if coords[2] else "~"]))
	var count := coords.count(true)
	var values : Array
	values.resize(count)
	for i in range(iter - 1, -1, -1):
		var offset := 1 << i
		values.fill(offset * scale)
		var coords_string := coords_model % values
		res.append(MODEL % [scorer, board, offset, "", target, coords_string, scorer, board, offset, "", scorer, board, -offset])
	
	for i in range(iter - 1, -1, -1):
		var offset := -(1 << i)
		values.fill(offset * scale)
		var coords_string := coords_model % values
		res.append(MODEL % [scorer, board, "", offset, target, coords_string, scorer, board, "", offset, scorer, board, -offset])
	return res
#endregion
