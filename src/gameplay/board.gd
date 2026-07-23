extends Node2D

@export var board_width := 5
@export var board_height := 5
var block_pointers := []

var block_scene: PackedScene = preload('res://src/gameplay/block.tscn')
var block_creation_queue = []

func str_to_type(str: String):
	match str:
		"equ": return 10
		"add": return 11
		"mul": return 12
		"sub": return 13
		"move": return 14
		"swap": return 15
		_: return int(str)

func load_level(id: String):
	var file = FileAccess.open("res://src/gameplay/levels/" + id, FileAccess.READ)
	var text = file.get_as_text()

	var content = []
	for section in text.split("\n\n"):
		var current_section = []
		for line in section.split("\n"):
			current_section.append(line.split(" "))	
		content.append(current_section)

	# board blocks
	for block in content[0]:
		var type = str_to_type(block[2])
		var locked = len(block) > 3 and block[3] != "0"
		make_block_at(Vector2(int(block[0]), int(block[1])), type, locked)

	# placeable blocks
	# todo

func _ready() -> void:
	# initialise pointer array
	for i in range(board_width):
		var row = []
		for j in range(board_height):
			row.append(null)
		block_pointers.append(row)
	
	load_level("dev1")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		advance_stage()

func make_block_at(pos, type, locked):
	var block_node := block_scene.instantiate()
	block_node.position = pos * 16
	block_node.next_type = type
	block_node.locked = locked
	block_node.update_visuals()
	$Blocks.add_child(block_node)

	block_pointers[int(pos.x)][int(pos.y)] = block_node

func queue_block_at(pos, type, locked):
	block_creation_queue.append([pos, type, locked])

func get_block_at(pos):
	return block_pointers[int(pos.x)][int(pos.y)]

func advance_stage():
	# apparently a prerelease reference
	# process operators
	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null or block.is_number(): continue

			var left = null if x == 0 else get_block_at(Vector2(x - 1, y))
			var right = null if x == board_width - 1 else get_block_at(Vector2(x + 1, y))
			var up = null if y == 0 else get_block_at(Vector2(x, y - 1))
			var down = null if y == board_height - 1 else get_block_at(Vector2(x, y + 1))

			match (block.get_type()):
				Operators.EQUALITY: Operators.eq(block, left, right, queue_block_at)
				Operators.ADDITION: Operators.add(block, left, right, up, down)
				Operators.MULTIPLICATION: Operators.multiply(block, left, right, up, down)
				Operators.SUBTRACTION: Operators.subtract(block, left, right)
				Operators.MOVEMENT: Operators.move(block, left, right, queue_block_at)
				Operators.SWAPIFICATION: Operators.swap(block, left, right)

	# create blocks
	for creation in block_creation_queue:
		make_block_at(creation[0], creation[1], creation[2])
	block_creation_queue = []

	# flush changes
	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null: continue
			
			if block.to_be_destroyed:
				block.queue_free()
				block_pointers[x][y] = null
			else:
				block.update_visuals()
