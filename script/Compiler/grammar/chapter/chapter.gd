@abstract
class_name GrammarChapterCompiler
extends GrammarCompiler
## 章节解析器。
##
## 抽象类，不能实例化。

## 章节元素。
enum ChapterMeta {
	## 类型。
	TYPE,
	## 细节。
	DETAIL,
	## 数据。
	DATA,
}

## 章节名称。
var chapter_name : String
