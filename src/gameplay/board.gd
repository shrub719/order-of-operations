extends Node2D

@export var board_width := 5
@export var board_height := 5
var block_pointers := []

var block_scene: PackedScene = preload('res://src/gameplay/block.tscn')
var block_creation_queue = []

var debug_layout_0 = [
	[2, 1, Operators.SUBTRACTION, false],
	[2, 2, Operators.MULTIPLICATION, true]
]

func load_layout(layout):
	for block in layout:
		make_block_at(Vector2(block[0], block[1]), block[2], block[3])

func debug_layout_1():
	make_block_at(Vector2(2,1), Operators.SUBTRACTION, false)
	make_block_at(Vector2(2,2), Operators.MULTIPLICATION, true)

	make_block_at(Vector2(3,2), Operators.MULTIPLICATION, false)

	make_block_at(Vector2(3,3), 6, false)
	make_block_at(Vector2(1,1), 7, false)
	make_block_at(Vector2(3,1), 2, false)

func debug_layout_2():
	make_block_at(Vector2(2,1), Operators.EQUALITY, false)
	make_block_at(Vector2(2,2), Operators.SUBTRACTION, true)
	make_block_at(Vector2(2,3), Operators.EQUALITY, false)

	make_block_at(Vector2(3,2), Operators.MULTIPLICATION, false)
	make_block_at(Vector2(1,2), Operators.MULTIPLICATION, false)

	make_block_at(Vector2(3,3), 2, false)
	make_block_at(Vector2(1,1), 3, false)

func _ready() -> void:
	# initialise pointer array
	for i in range(board_width):
		var row = []
		for j in range(board_height):
			row.append(null)
		block_pointers.append(row)
	
	debug_layout_2()

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
