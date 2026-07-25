extends Node

var can_drag_blocks := true
var level_order = [
	"main",
	"test1",
	"test2",
	"train",
	"cascade",
	"simulswap-1",
	"simulswap-2",
	"simulswap-3",
]
var level_index = 0

func level():
	return level_order[level_index]
