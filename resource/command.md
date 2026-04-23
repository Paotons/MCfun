{
	"execute" : [
		# 开头 由于都是继承了这个 所以每个都要用一个空值区分开
		{"type" : "options", "id" : 0, "extends" : -2, 
		"items" : ["as", "at", "run", "positioned", "if", "unless", "in", "align", "anchored", "facing", "rotated"], 
		"goto" : [1, 1, 950, 11, 3, 3, 9, 15, 17, 19, 23]}, # 0
		
		{"type" : "null", "id" : 899, "extends" : -2, "goto" : 999},
		# as at
		{"type" : "selector", "id" : 1, "extends" : 0, "goto" : 0}, # 1
		
		{"type" : "null", "id" : 900, "extends" : -2, "goto" : 999},
		# if/unless-entity
		{"type" : "selector", "id" : 2, "extends" : 3, "goto" : 0}, # 2
		
		{"type" : "null", "id" : 901, "extends" : -2, "goto" : 999},
		# if unless
		{"type" : "options", "id" : 3, "extends" : 0,
		"items" : ["entity", "block", "blocks", "score"], "goto" : [2, 4, 6, 28]}, # 3
		
		{"type" : "null", "id" : 902, "extends" : -2, "goto" : 999},
		# if/unless-block
		{"type" : "coords", "id" : 4, "extends" : 3}, # 4
		{"type" : "space_item", "id" : 5, "extends" : 4, "goto" : 0}, # 5
		
		{"type" : "null", "id" : 903, "extends" : -2, "goto" : 999},
		# if/unless-blocks
		{"type" : "coords", "id" : 6, "extends" : 3}, # 6
		{"type" : "coords", "id" : 7, "extends" : 6}, # 7
		{"type" : "space_item", "id" : 8, "extends" : 7, "goto" : 0}, # 8
		
		{"type" : "null", "id" : 904, "extends" : -2, "goto" : 999},
		# in
		{"type" : "options", "id" : 9, "extends" : 0, "items" : ["overworld", "the_nether", "the_end"]}, # 9
		{"type" : "null", "id" : 10, "extends" : 9, "goto" : 0}, # 10
		
		{"type" : "null", "id" : 905, "extends" : -2, "goto" : 999},
		# positioned
		{"type" : "coords", "id" : 11, "extends" : 0, "goto" : 0}, # 11
		{"type" : "options", "id" : 12, "extends" : 0, "items" : ["as"]}, # 12
		{"type" : "null", "id" : 13, "extends" : 12, "custom" : "cmp"}, # 13
		{"type" : "selector", "id" : 14, "extends" : 13, "goto" : 0}, # 14
		
		{"type" : "null", "id" : 906, "extends" : -2, "goto" : 999},
		# align
		{"type" : "options", "id" : 15, "extends" : 0, "items" : ["x", "y", "z", "xy", "xz", "yz", "xyz"]}, # 15
		{"type" : "null", "id" : 16, "extends" : 15, "goto" : 0}, # 16
		
		{"type" : "null", "id" : 907, "extends" : -2, "goto" : 999},
		# anchored
		{"type" : "options", "id" : 17, "extends" : 0, "items" : ["feet", "eyes"]}, # 17
		{"type" : "null", "id" : 18, "extends" : 17, "goto" : 0}, # 18
		
		{"type" : "null", "id" : 908, "extends" : -2, "goto" : 999},
		# facing
		{"type" : "coords", "id" : 19, "extends" : 0, "goto" : 0}, # 19
		{"type" : "options", "id" : 20, "extends" : 0, "items" : ["entity"]}, # 20
		{"type" : "null", "id" : 21, "extends" : 20, "custom" : "cmp"}, # 21
		{"type" : "selector", "id" : 22, "extends" : 21, "goto" : 0}, # 22
		
		{"type" : "null", "id" : 909, "extends" : -2, "goto" : 999},
		# rotated
		{"type" : "float", "id" : 23, "extends" : 0}, # 23
		{"type" : "float", "id" : 24, "extends" : 23, "goto" : 0}, # 24
		{"type" : "options", "id" : 25, "extends" : 0, "items" : ["as"]}, # 25
		{"type" : "null", "id" : 26, "extends" : 25, "custom" : "cmp"}, # 26
		{"type" : "selector", "id" : 27, "extends" : 26, "goto" : 0}, # 27
		
		{"type" : "null", "id" : 910, "extends" : -2, "goto" : 999},
		# if/unless-score
		{"type" : "selector", "id" : 28, "extends" : 3}, # 28
		{"type" : "string", "id" : 29, "extends" : 28}, # 29
		{"type" : "options", "id" : 30, "extends" : 29,
		"items" : ["matches", "=", ">=", "<=", "<", ">"], "goto" : [31, 32, 32, 32, 32, 32]}, # 30
		
		{"type" : "null", "id" : 911, "extends" : -2, "goto" : 999},
		# if/unless-score-matches
		{"type" : "scope", "id" : 31, "extends" : 30, "goto" : 0}, # 31
		
		{"type" : "null", "id" : 912, "extends" : -2, "goto" : 999},
		# if/unless-score-*
		{"type" : "selector", "id" : 32, "extends" : 30}, # 32
		{"type" : "string", "id" : 33, "extends" : 32, "goto" : 0}, # 33
		
		{"type" : "null", "id" : 998, "extends" : -2, "goto" : 999},
		# run
		{"type" : "command", "id" : 950, "extends" : 0},
		{"type" : "null", "id" : 999, "extends" : 900},
	],
	"gamemode" : [
		{"type" : "options", "id" : 0, "extends" : -1, "items" : ["c", "a", "s"], "is_end" : true},
		{"type" : "selector", "id" : 1, "extends" : 0, "is_end" : true}
	],
	"reload" : [
		{"type" : "null", "id" : 0, "extends" : -1, "is_end" : true},
	],
	"give" : [
		{"type" : "selector", "id" : 0, "extends" : -1},
		{"type" : "space_item", "id" : 1, "extends" : 0, "is_end" : true},
		{"type" : "int", "id" : 2, "extends" : 1, "is_end" : true},
		{"type" : "int", "id" : 3, "extends" : 2, "is_end" : true},
		{"type" : "dictionary", "id" : 4, "extends" : 3, "is_end" : true},
	],
	"tp" : [
		{"type" : "selector", "id" : 0, "extends" : -1, "goto" : 2, "is_end" : true}, # 0
		{"type" : "coords", "id" : 1, "extends" : -1, "is_end" : true}, # 1
		{"type" : "null", "id" : 800, "extends" : 1, "goto" : 5, "custom" : "cmp"},
		
		{"type" : "null", "id" : 900, "extends" : -2, "goto" : 999},
		# 目标
		{"type" : "selector", "id" : 2, "extends" : 0, "goto" : 998, "is_end" : true}, # 2
		{"type" : "coords", "id" : 3, "extends" : 0, "is_end" : true}, # 3
		{"type" : "null", "id" : 4, "extends" : 3, "goto" : 5, "custom" : "cmp"}, # 4
		
		{"type" : "null", "id" : 901, "extends" : -2, "goto" : 999},
		# 方向
		{"type" : "float", "id" : 5, "extends" : -2, "goto" : 8, "is_end" : false}, # 5
		{"type" : "options", "id" : 6, "extends" : -2, "items" : ["facing"]}, # 6
		{"type" : "null", "id" : 7, "extends" : 6, "goto" : 9, "custom" : "cmp"}, # 7
		
		{"type" : "null", "id" : 902, "extends" : -2, "goto" : 999},
		# rx
		{"type" : "float", "id" : 8, "extends" : 5, "goto" : 998, "is_end" : true}, # 8
		
		{"type" : "null", "id" : 903, "extends" : -2, "goto" : 999},
		# facing
		{"type" : "coords", "id" : 9, "extends" : -2, "goto" : 998}, # 9
		{"type" : "options", "id" : 10, "extends" : -2, "items" : ["entity"]}, # 10
		{"type" : "null", "id" : 11, "extends" : 10, "goto" : 12, "custom" : "cmp"}, # 11
		
		{"type" : "null", "id" : 904, "extends" : -2, "goto" : 999},
		# facing-entity
		{"type" : "selector", "id" : 12, "extends" : 11, "goto" : 998}, # 12
		
		{"type" : "null", "id" : 902, "extends" : -2, "goto" : 999},
		# 检测区块加载。
		{"type" : "options", "id" : 998, "extends" : -2, "items" : ["true", "false"]},
		
		{"type" : "null", "id" : 999, "extends" : -2}
	]
	
 }
