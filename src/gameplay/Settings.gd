extends Node

var can_drag_blocks := true
var level_order = [
	"main",
	"playground",
	"tutorial-add",
	"tutorial-chain",
	"tutorial-operators",
	"fortress",
	"cascade",
	"tutorial-swap-1",
	"mirror-1",
	"mirror-2",
	"tutorial-swap-2",
	"simulswap-1",
	"simulswap-2",
	"simulswap-3",
	"shrub",
	"swapadd-1",
	"swapadd-2",
	"shift-1",
	"shift-2",
	"train",
	"buckle",
	"lovers-1",
	"lovers-2",
]
var level_index = 0

func level():
	return level_order[level_index]

func level_name_from_file(id):
	var file = FileAccess.open("res://src/gameplay/levels/" + id, FileAccess.READ)
	var text = file.get_as_text()
	# FUCK OFF WINDOWS
	text = text.remove_char(ord("\r"))

	var content = []
	for section in text.split("\n\n"):
		var current_section = []
		for line in section.split("\n"):
			if line == "": continue
			current_section.append(line.split(" "))	
		content.append(current_section)

	return " ".join(content[0][0])
