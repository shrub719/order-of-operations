extends Node

var can_drag_blocks := true
var level_order = [
	"train",
	"cascade",
]
var level_index = 0

func level():
	return level_order[level_index]
