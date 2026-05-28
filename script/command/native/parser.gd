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
		"scoreboard" : return _parse_scoreboard()
		"fill" : return _parse_fill()
	
	return ""

func _parse_string() -> String:
	var element : StringElement = commamd.get_element(0)
	return element.get_valid_string()

#region tp
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
	var coords : Array[bool] = _string_coord_to_bools(coord)
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
#endregion

#region scoreboard
func _parse_scoreboard() -> String:
	const MODE_OPTION_INDEX := 0
	
	const PLAYERS_MODE := 0
	var mode := (commamd.get_element(MODE_OPTION_INDEX) as OptionElement).get_option_index()
	match mode:
		PLAYERS_MODE: return _parse_scoreboard_players()
	return ""

#region scoreboard players
func _parse_scoreboard_players() -> String:
	const MODE_OPTION_INDEX := 1
	
	const POSITION_MODE := 0
	var mode := (commamd.get_element(MODE_OPTION_INDEX) as OptionElement).get_option_index()
	match mode:
		POSITION_MODE: return _parse_scoreboard_players_position()
	
	return ""

func _parse_scoreboard_players_position() -> String:
	const DEFAULT_ITER := 26
	
	const TARGET_INDEX := 2
	const COORD_INDEX := 3
	const SCORER_INDEX := 4
	const BOARD_INDEX := 5
	const MODE_INDEX := 6
	const ITER_INDEX := 7
	
	const SET_MODE := 0
	
	var count := commamd.get_element_count()
	var target := (commamd.get_element(TARGET_INDEX) as SelectorElement).get_valid_string()
	var coord := (commamd.get_element(COORD_INDEX) as OptionElement).get_valid_string()
	var scorer := (commamd.get_element(SCORER_INDEX) as SelectorElement).get_valid_string()
	var board := (commamd.get_element(BOARD_INDEX) as WordElement).get_valid_string()
	var mode := (commamd.get_element(MODE_INDEX) as OptionElement).get_option_index() if MODE_INDEX < count - 2 else SET_MODE
	var iter := (commamd.get_element(ITER_INDEX) as IntElement).get_value() if ITER_INDEX < count - 2 else DEFAULT_ITER
	var coords : Array[bool] = _string_coord_to_bools(coord)
	return _parse_scoreboard_players_position_do(target, coords, scorer, board, mode == SET_MODE, iter)

func _parse_scoreboard_players_position_do(target : String, coord : Array[bool], scorer : String, board : String, is_set : bool, iter : int) -> String:
	var res : PackedStringArray
	
	var target_tag := "_temp_" + StrT.rand_base63(16)
	res.append("execute at %s run summon armor_stand %s" % [target, target_tag])
	res.append("tag @e[name=%s] add %s" % [target_tag, target_tag])
	var tag_target := "@e[tag=%s]" % target_tag
	
	var scorer_tag := "_temp_" + StrT.rand_base63(16) if scorer.begins_with("@") else ""
	var tag_scorer := scorer
	if not scorer_tag.is_empty():
		res.append("tag %s add %s" % [scorer, scorer_tag])
		tag_scorer = "@e[tag=%s]" % scorer_tag
	
	if is_set:
		res.append("scoreboard players set %s %s 0" % [tag_scorer, board])
	res.append_array(_parse_scoreboard_players_position_tp(tag_target, tag_scorer, board, coord, iter))
	
	res.append("kill %s" % [tag_target])
	if not scorer_tag.is_empty():
		res.append("tag %s remove %s" % [tag_scorer, scorer_tag])
	return "\n".join(res)

func _parse_scoreboard_players_position_tp(target : String, scorer : String, board : String, coords : Array[bool], iter : int) -> PackedStringArray:
	var res : PackedStringArray
	var temp_scorer := "_temp_" + StrT.rand_base63(16) # 记录方向的
	
	res.append("execute as %s at @s run tp @s %s %s %s" % [target, "~" if coords[0] else "0", "~" if coords[1] else "0", "~" if coords[2] else "0"])
	res.append("scoreboard players set %s %s 0" % [temp_scorer, board])
	res.append("execute positioned 0 0 0 as %s if entity @s[x=0,y=0,z=0,dx=%d,dy=%d,dz=%d] run scoreboard players set %s %s 1" % [
		target, 1 << iter if coords[0] else 1, 1 << iter if coords[1] else 1, 1 << iter if coords[2] else 1, temp_scorer, board
	])
	
	var coord_model := "~%s ~%s ~%s" % ["%d" if coords[0] else "", "%d" if coords[1] else "", "%d" if coords[2] else ""]
	for i in range(iter - 1, -1, -1):
		var offset := 1 << i
		res.append("execute if score %s %s matches 1..1 positioned 0 0 0 as %s if entity @s[rm=%d] run scoreboard players add %s %s %d" % [
			temp_scorer, board, target, offset, scorer, board, offset
		])
		res.append("execute if score %s %s matches 1..1 positioned 0 0 0 as %s if entity @s[rm=%d] at @s run tp @s %s" % [
			temp_scorer, board, target, offset, coord_model % -offset
		])
		
	
	for i in range(iter - 1, -1, -1):
		var offset := 1 << i
		res.append("execute if score %s %s matches 0..0 positioned 0 0 0 as %s if entity @s[rm=%d] run scoreboard players remove %s %s %d" % [
			temp_scorer, board, target, offset, scorer, board, offset
		])
		res.append("execute if score %s %s matches 0..0 positioned 0 0 0 as %s if entity @s[rm=%d] at @s run tp @s %s" % [
			temp_scorer, board, target, offset, coord_model % offset
		])
	
	res.append("scoreboard players reset %s %s" % [temp_scorer, board])
	return res
#endregion
#endregion

#region fill
func _parse_fill() -> String:
	const FROM_COORD_INDEX := 0
	const TO_COORD_INDEX := 1
	const BLOCK_NAME_INDEX := 2
	const MODE_INDEX := 3
	const REPLACED_BLOCK_INDEX := 4
	
	const HOLLOW_MODE := 1
	const OUTLINE_MODE := 3
	const REPLACE_MODE := 4
	var count := commamd.get_element_count()
	
	var from := commamd.get_element(FROM_COORD_INDEX) as CoordsElement
	var to := commamd.get_element(TO_COORD_INDEX) as CoordsElement
	var block := (commamd.get_element(BLOCK_NAME_INDEX) as SpaceItemElement).get_valid_string()
	var mode := (commamd.get_element(MODE_INDEX) as OptionElement).get_option_index() if MODE_INDEX < count - 2 else REPLACE_MODE
	
	match mode:
		HOLLOW_MODE:
			return _parse_fill_hollow(from, to, block)
		OUTLINE_MODE:
			return _parse_fill_outline(from, to, block)
		REPLACE_MODE:
			var rblock := (commamd.get_element(REPLACED_BLOCK_INDEX) as SpaceItemElement).get_value_string() if REPLACED_BLOCK_INDEX < count - 2 else ""
			return _parse_fill_replace(from, to, block, rblock)
		_:
			return _parse_fill_normal(from, to, block, mode)

func _parse_fill_normal(from : CoordsElement, to : CoordsElement, block : String, mode : int) -> String:
	const DESTROY_MODE := 0
	const KEEP_MODE := 2
	const MODE_STRING_MAP : Dictionary[int, String] = {
		DESTROY_MODE : "destroy",
		KEEP_MODE : "keep",
	}
	
	const MAX_SIZE := 32768
	var mode_string := MODE_STRING_MAP[mode]
	
	var aabb := from.get_tile_aabb(to)
	if aabb == AABB() or ceili(aabb.get_volume()) < MAX_SIZE:
		return "fill %s %s %s %s" % [from.get_valid_string(), to.get_valid_string(), block, mode_string]
	
	var x_m := from.get_coord(0).get_coord_mode()
	var y_m := from.get_coord(1).get_coord_mode()
	var z_m := from.get_coord(2).get_coord_mode()
	
	var res : PackedStringArray
	for naabb in AABBT.split_aabbi(aabb):
		res.append("fill %s %s %s %s" % [CoordsElement.create_tile_coords_string(naabb.position, x_m, y_m, z_m), CoordsElement.create_tile_coords_string(naabb.end - Vector3.ONE, x_m, y_m, z_m), block, mode_string])
	return "\n".join(res)

func _parse_fill_hollow(from : CoordsElement, to : CoordsElement, block : String) -> String:
	const MAX_SIZE := 32768
	const AIR_BLOCK := "minecraft:air"
	
	var aabb := from.get_tile_aabb(to)
	if aabb == AABB() or ceili(aabb.get_volume()) < MAX_SIZE:
		return "fill %s %s %s hollow" % [from.get_valid_string(), to.get_valid_string(), block]
	
	var res : PackedStringArray
	var x_m := from.get_coord(0).get_coord_mode()
	var y_m := from.get_coord(1).get_coord_mode()
	var z_m := from.get_coord(2).get_coord_mode()
	
	var hollow_aabb := AABBT.get_aabb_hollow(aabb)
	if hollow_aabb != AABB():
		res.append(_parse_fill_replace(
			CoordsElement.create(CoordsElement.create_tile_coords_string(hollow_aabb.position, x_m, y_m, z_m), 0),
			CoordsElement.create(CoordsElement.create_tile_coords_string(hollow_aabb.end, x_m, y_m, z_m), 0),
			AIR_BLOCK
		))
	res.append(_parse_fill_outline(from, to, block))
	
	return "\n".join(res)

func _parse_fill_outline(from : CoordsElement, to : CoordsElement, block : String) -> String:
	const MAX_SIZE := 32768
	
	var aabb := from.get_tile_aabb(to)
	if aabb == AABB() or ceili(aabb.get_volume()) < MAX_SIZE:
		return "fill %s %s %s outline" % [from.get_valid_string(), to.get_valid_string(), block]
	
	var x_m := from.get_coord(0).get_coord_mode()
	var y_m := from.get_coord(1).get_coord_mode()
	var z_m := from.get_coord(2).get_coord_mode()
	
	var res : PackedStringArray
	for naabb : AABB in AABBT.get_aabb_outline(aabb).values():
		res.append(_parse_fill_replace(
			CoordsElement.create(CoordsElement.create_tile_coords_string(naabb.position, x_m, y_m, z_m), 0),
			CoordsElement.create(CoordsElement.create_tile_coords_string(naabb.end - Vector3.ONE, x_m, y_m, z_m), 0),
			block
		))
	
	return "\n".join(res)

func _parse_fill_replace(from : CoordsElement, to : CoordsElement, block : String, rblock := "") -> String:
	const MAX_SIZE := 32768
	
	var aabb := from.get_tile_aabb(to)
	if aabb == AABB() or ceil(aabb.get_volume()) < MAX_SIZE:
		return "fill %s %s %s%s" % [from.get_valid_string(), to.get_valid_string(), block, "" if rblock.is_empty() else " replace " + rblock]
	
	var x_m := from.get_coord(0).get_coord_mode()
	var y_m := from.get_coord(1).get_coord_mode()
	var z_m := from.get_coord(2).get_coord_mode()
	
	var res : PackedStringArray
	for naabb in AABBT.split_aabbi(aabb):
		res.append("fill %s %s %s%s" % [CoordsElement.create_tile_coords_string(naabb.position, x_m, y_m, z_m), CoordsElement.create_tile_coords_string(naabb.end - Vector3.ONE, x_m, y_m, z_m), block, "" if rblock.is_empty() else " replace " + rblock])
	
	return "\n".join(res)

#endregion

# 把字符串轴转化为多布尔坐标轴。
func _string_coord_to_bools(string : String) -> Array[bool]:
	return [string.find("x") != -1, string.find("y") != -1, string.find("z") != -1]


