extends Node

var can_drag_blocks := true
var level_order = []
var level_index = 0

func _ready() -> void:
	# load level order
	var file = FileAccess.open("res://src/gameplay/levels/LEVEL-ORDER.txt", FileAccess.READ)
	var text = file.get_as_text()
	# FUCK OFF WINDOWS
	text = text.remove_char(ord("\r"))
	for line in text.split("\n"):
		if line == "": continue
		level_order.append(line + ".txt")

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
