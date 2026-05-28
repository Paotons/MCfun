class_name AABBT
extends Object
## 矩形工具。
##
## 静态类。

# 此函数由 DeepSeek 生成。
## 给定任意 AABB，切成不超过 max_blocks 的多个 AABB
static func split_aabbi(aabb: AABB, max_blocks: int = 32768) -> Array[AABB]:
	var result : Array[AABB]
	var queue_aabb : Array[AABB] = [aabb]
	
	while not queue_aabb.is_empty():
		aabb = queue_aabb.pop_back() as AABB
		
		if ceili(aabb.get_volume()) <= max_blocks:
			result.append(aabb)
			continue
		
		var longest_axis := aabb.get_longest_axis_index()
		var split_point := roundi((aabb.position[longest_axis] + aabb.end[longest_axis]) / 2.0)
		var aabb1 := AABB(aabb)
		var aabb2 := AABB(aabb)
		
		aabb1.end[longest_axis] = split_point
		aabb2.position[longest_axis] = split_point
		aabb2.end[longest_axis] = aabb2.end[longest_axis] - split_point
		
		queue_aabb.append(aabb1)
		queue_aabb.append(aabb2)
	return result

# 此函数由 DeepSeek 生成。
## 返回一个矩形的轮廓。类型为[code] Dictionary[normal : Vector3, aabb : AABB][/code]。
static func get_aabb_outline(aabb: AABB, length := 1.0) -> Dictionary[Vector3, AABB]:
	var min_pos := aabb.position
	var max_pos := aabb.end
	
	return Dictionary({
		Vector3.LEFT : AABB(Vector3(min_pos.x, min_pos.y, min_pos.z), Vector3(length, aabb.size.y - length, aabb.size.z)),   # -x
		Vector3.UP : AABB(Vector3(min_pos.x, max_pos.y - length, min_pos.z), Vector3(aabb.size.x - length, length, aabb.size.z)),   # +y
		Vector3.RIGHT : AABB(Vector3(max_pos.x - length, min_pos.y + length, min_pos.z), Vector3(length, aabb.size.y - length, aabb.size.z)),   # +x
		Vector3.DOWN : AABB(Vector3(min_pos.x + length, min_pos.y, min_pos.z), Vector3(aabb.size.x - length, length, aabb.size.z)),   # -y
		
		Vector3.BACK : AABB(Vector3(min_pos.x + length, min_pos.y + length, min_pos.z), Vector3(aabb.size.x - 2.0 * length, aabb.size.y - 2.0 * length, length)),   # -z
		Vector3.FORWARD : AABB(Vector3(min_pos.x + length, min_pos.y + length, max_pos.z - length), Vector3(aabb.size.x - 2.0 * length, aabb.size.y - 2.0 * length, length))  # +z
	}, TYPE_VECTOR3, &"", null, TYPE_AABB, &"", null)

## 返回一个新矩形，是指定矩形的一定厚度的空心矩形。
static func get_aabb_hollow(aabb : AABB, length := 1.0) -> AABB:
	var size := aabb.size - Vector3.ONE * 2.0 * length
	return AABB() if size[size.min_axis_index()] < 0.0 else AABB(aabb.position + Vector3.ONE * length, size)
