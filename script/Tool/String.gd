@tool @abstract
class_name StrT
extends Object
## 静态，字符串工具。
##
## 缩写 [code]StringTool[/code]。

# 空字符的正则表达式。
static var _is_empty_chr_regex := RegEx.create_from_string(r"^\p{Zs}$")
static var _find_empty_chr_regex := RegEx.create_from_string(r"^\p{Zs}")
## 如果是空字符串，返回 [code]true[/code]。
static func is_empty_string(chr_ord : int) -> bool:
	return _is_empty_chr_regex.search(String.chr(chr_ord)) != null
## 向后查找，遇到空字符返回序列。
static func find_empty(text : String, start : int) -> int:
	text = text.substr(start)
	if text.is_empty(): return -1
	var result := _find_empty_chr_regex.search(text)
	return text.length() if result == null else result.get_end() + start
## 向前查找，遇到非空字符返回序列。
static func rfind_empty(text : String, start : int) -> int:
	while start >= 0:
		if is_empty_string(text.unicode_at(start)):
			return start
		start -= 1
	return -1

# 非空字符串的表达式。
static var _find_unempty_chr_regex := RegEx.create_from_string(r"^\p{Zs}+")
## 向后查找，遇到非空字符返回序列。
static func find_unempty(text : String, start : int) -> int:
	text = text.substr(start)
	if text.is_empty(): return -1
	var result := _find_unempty_chr_regex.search(text)
	return start if result == null or result.get_end() == text.length() else result.get_end() + start
## 向前查找，遇到非空字符返回序列。
static func rfind_unempty(text : String, start : int) -> int:
	while start >= 0:
		if not is_empty_string(text.unicode_at(start)):
			return start
		start -= 1
	return -1

## 获取序列所在的字符串。
static func get_string(text : String, start : int) -> String:
	var s := rfind_empty(text, start)
	var e := find_empty(text, start + 1)
	s = 0 if s == -1 else s + 1
	e = text.length() if e == -1 else e
	return text.substr(s, e - s)

# 字母的正则表达式。
static var _is_letter_chr_regex := RegEx.create_from_string(r"^\p{L}|\p{Pc}$")
static var _find_letter_chr_regex := RegEx.create_from_string(r"^[\p{L}\p{Pc}]+")
## 如果是单词，返回 [code]true[/code]。
static func is_letter_char_ord(chr_ord : int) -> bool:
	return _is_letter_chr_regex.search(String.chr(chr_ord)) != null
## 向后查找，遇到非单词字符返回序列。
static func find_unletter(text : String, start : int) -> int:
	text = text.substr(start)
	if text.is_empty(): return -1
	var result := _find_letter_chr_regex.search(text)
	return start if result == null else result.get_end() + start
## 向前查找，遇到非单词字符返回序列。
static func rfind_unletter(text : String, start : int) -> int:
	while start >= 0:
		if not is_letter_char_ord(text.unicode_at(start)):
			return start
		start -= 1
	return -1
## 获取序列所在的单词。
static func get_letter(text : String, start : int) -> String:
	var s := rfind_unletter(text, start - 1)
	var e := find_unletter(text, start)
	s = 0 if s == -1 else s + 1
	e = text.length() if e == -1 else e
	return text.substr(s, e - s)

## 向后查找，遇到可用的引号返回序列。
static func find_quotation(text : String, start : int) -> int:
	var lenght := text.length()
	while start < lenght:
		start = text.find("\"", start)
		if start == -1: break
		if start == 0 or text[start - 1] != "\\":
			return start
		start += 1
	return -1
## 向前查找，遇到可用的引号返回序列。
static func rfind_quotation(text : String, start : int) -> int:
	while start >= 0:
		start = text.rfind("\"", start)
		if start == -1: break
		if start == 0 or text[start - 1] != "\\":
			return start
		start -= 1
	return -1
## 获取序列所在的引号字符串，如果 [param include] 为 [code]false[/code]，则不包括括号。
static func get_quotation(text : String, start : int, include := true) -> String:
	var s := rfind_quotation(text, start)
	if s == -1: return ""
	var e := find_quotation(text, start + 1)
	return text.substr(s, (text.length() if e == -1 else e) - s) if include else text.substr(s + 1, (text.length() if e == -1 else e - 1) - s - 1)
## 如果字符串是引号包括的，返回 [code]true[/code]。
static func is_quotation(text : String) -> bool:
	return text.length() >= 2 and text.begins_with("\"") and text.ends_with("\"") and not text.ends_with("\\\"")

## 向前查找，遇到和最开始不一样的字符串返回。
static func rfind_diverse(text : String, start : int) -> int:
	var od := text.unicode_at(start)
	while start > 0:
		start -= 1
		if text.unicode_at(start) != od:
			return start
	return -1
## 向后查找，遇到和最开始不一样的字符串返回。
static func find_diverse(text : String, start : int) -> int:
	var od := text.unicode_at(start)
	var length := text.length()
	start += 1
	while start < length:
		if text.unicode_at(start) != od:
			return start
		start += 1
	return -1
## 获取当前位置周围重复出现的次数。
static func get_repeat_count(text : String, start : int) -> int:
	var s := rfind_diverse(text, start - 1)
	var e := find_diverse(text, start)
	return (text.length() if e == -1 else e) - s - 1

## 获取两模糊字符串相似性的权重，以 [code]256[/code] 为普通权重。
static func get_fuzzy_weight(a : String, b : String) -> int:
	var res := 0
	var less : String
	var longer : String
	
	if a.length() < b.length():
		less = a
		longer = b
	else:
		less = b
		longer = a
	
	res += 256 - mini(256, 8 * (longer.length() - less.length())) # 长度惩罚
	
	var chain := 0
	var i := 0
	for chr in less:
		var i_ := longer.find(chr, i)
		if i_ == -1:
			break
		res += 256 # 主要加权
		
		chain = chain + 1 if i_ == i else 0
		res += chain * 256 # 连续性超级加权 平方增长
		i = i_ + 1
	
	return res
