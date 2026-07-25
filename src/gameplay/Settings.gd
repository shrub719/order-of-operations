extends Node

var can_drag_blocks := true
var level_order = [
	#"playground",
	"test1",
	"test2",
	"cascade",
	"simulswap-1",
	"simulswap-2",
	"simulswap-3",
	"train",
	"buckle",
	"shift-1",
	"shift-2",
]
var level_index = 9

func level():
	return level_order[level_index]
