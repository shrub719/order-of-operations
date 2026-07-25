class_name Board
extends Node2D
@onready var SFX: SFXManager = $"/root/Sfxmanager"

@export var board_width := 5
@export var board_height := 5
@export var drawer : Sprite2D
const DRAWER_WIDTH := 3
const DRAWER_HEIGHT := 5
var block_pointers := []
var block_cache := []
var drawer_block_pointers := []

var block_scene: PackedScene = preload('res://src/gameplay/block.tscn')
var block_creation_queue = []

func str_to_type(st: String):
	match st:
		"equ": return Operators.EQUALITY
		"add": return Operators.ADDITION
		"mul": return Operators.MULTIPLICATION
		"sub": return Operators.SUBTRACTION
		"swap": return Operators.SWAPIFICATION
		"gequ": return Operators.GLYPH_EQUALITY
		"gswap": return Operators.GLYPH_SWAPIFICATION
		"vswap": return Operators.VERTICAL_SWAPIFICATION
		_: return int(st)

func load_level(id: String):
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

	for x in range(board_width):
		for y in range(board_height):
			$BackgroundTiles.set_cell(Vector2i(x, y))

	var title = " ".join(content[0][0])
	get_parent().set_title(title)

	board_width = int(content[0][1][0])
	board_height = int(content[0][1][1])

	for x in range(board_width):
		for y in range(board_height):
			var colour = 0 if (x + y) % 2 == 0 else 1
			$BackgroundTiles.set_cell(Vector2i(x, y), 1, Vector2i(colour, 0))

	# purge children #homicide
	for row in block_pointers:
		for block in row:
			if block != null: block.queue_free()
	for row in drawer_block_pointers:
		for block in row:
			if block != null: block.queue_free()

	# initialise pointer array
	block_pointers = []
	block_cache = []
	for i in range(board_width):
		var row = []
		var cache_row = []
		for j in range(board_height):
			row.append(null)
			cache_row.append(null)
		block_pointers.append(row)
		block_cache.append(cache_row)

	drawer_block_pointers = []
	for i in range(DRAWER_WIDTH):
		var row = []
		for j in range(DRAWER_HEIGHT): 
			row.append(null)
		drawer_block_pointers.append(row)

	# board blocks
	for block in content[1]:
		var type = str_to_type(block[2])
		make_block_at(Vector2(int(block[0]), int(block[1])), type, true)

	# drawer blocks
	for block in content[2]:
		var type = str_to_type(block[2])
		make_block_at(Vector2(int(block[0]), int(block[1])), type, false)
	
	update_all_hitboxes()

	# move board to be centred
	position = Vector2(140, get_viewport_rect().size.y / 2) - Vector2(8 * board_width, 8 * board_height)
	# fix drawer blocks position
	$DrawerBlocks.position = to_local(drawer.global_position)

# THIS IS FOR LEVEL CREATION ONLY TODO REMOVE
func _input(event):
	if Settings.level() == "playground" and event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		var x = 0
		var y = 0
		for type in range(1, 16):
			var existing_block = drawer_block_pointers[x][y]
			if existing_block != null: existing_block.queue_free()
			make_block_at(Vector2(x, y), type, false)
			y += 1
			if y >= DRAWER_HEIGHT:
				x += 1
				y = 0
			print(x, y)

	if Settings.level() == "playground" and event is InputEventKey and event.pressed and event.keycode == KEY_E:
		var x = 0
		var y = 0
		for type in range(16, 19):
			var existing_block = drawer_block_pointers[x][y]
			if existing_block != null: existing_block.queue_free()
			make_block_at(Vector2(x, y), type, false)
			y += 1
			if y >= DRAWER_HEIGHT:
				x += 1
				y = 0
			print(x, y)

func _ready() -> void:
	reset()

func reset():
	SFX.board_entry()
	load_level(Settings.level())

func cache_board():
	# store information about every tile on the board
	for x in range(board_width):
		for y in range(board_height):
			# reset block cache
			block_cache[x][y] = null
			# and assign a value if theres a block present
			var block = block_pointers[x][y]
			if block == null: continue
			block_cache[x][y] = block.encode()

func load_cache():
	# clear all tiles
	for child in $Blocks.get_children():
		child.queue_free()
	
	for x in range(board_width):
		for y in range(board_height):
			# reset the pointer
			block_pointers[x][y] = null 

			var block_data = block_cache[x][y]
			if block_data == null: continue
			# cached block here
			var block: Block = block_scene.instantiate()
			block.position = Vector2(x, y) * 16
			block.old_position = block.position
			block.next_type = block_data.type
			block.locked = block_data.is_locked
			block.on_board = true
			block.update_visuals()

			$Blocks.add_child(block)
			block_pointers[x][y] = block
	
	update_all_hitboxes()

func make_block_at(pos, type, on_board):
	var block_node := block_scene.instantiate()
	block_node.position = pos * 16
	block_node.old_position = block_node.position
	block_node.next_type = type
	block_node.locked = on_board
	block_node.on_board = on_board
	block_node.update_visuals()

	if on_board:
		$Blocks.add_child(block_node)
		block_pointers[int(pos.x)][int(pos.y)] = block_node
	else:
		$DrawerBlocks.add_child(block_node)
		drawer_block_pointers[int(pos.x)][int(pos.y)] = block_node
	
	update_all_hitboxes()

func queue_block_at(pos, type):
	block_creation_queue.append([pos, type])

func get_block_at(pos):
	return block_pointers[int(pos.x)][int(pos.y)]

func get_nearest_tile(coord: Vector2, width, height):
	var x = coord.x
	var y = coord.y
	var closest_coord = Vector2(roundf(x), roundf(y))

	var distance = (closest_coord - coord).length()

	if not (0 <= closest_coord.x and closest_coord.x < width and 0 <= closest_coord.y and closest_coord.y < height):
		return Vector2(-1, -1)
	elif distance >= 0.7:	# about sqrt 2 / 2
		return Vector2(-1, -1)
	else:
		return closest_coord

func remove_reference(block):
	var old_coords = block.old_position / 16
	# temp fix for a "double click" issue
	if old_coords.x != int(old_coords.x) or old_coords.y != int(old_coords.y):
		print("double click bug")
		return
	if block.on_board:
		block_pointers[old_coords.x][old_coords.y] = null
	else:
		drawer_block_pointers[old_coords.x][old_coords.y] = null

func snap_block(block):
	# round to nearrest coord
	# if close enough (and empty), then remove old reference and add new one
	var board_position = block.global_position - $Blocks.global_position
	var drawer_position = block.global_position - $DrawerBlocks.global_position

	var board_coords = board_position / 16
	var drawer_coords = drawer_position / 16

	var board_tile = get_nearest_tile(board_coords, board_width, board_height)
	var drawer_tile = get_nearest_tile(drawer_coords, DRAWER_WIDTH, DRAWER_HEIGHT)

	if board_tile != Vector2(-1, -1) and block_pointers[board_tile.x][board_tile.y] == null:
		remove_reference(block)
		block.reparent($Blocks)
		block.position = board_tile * 16
		block.on_board = true
		block_pointers[board_tile.x][board_tile.y] = block
		SFX.place()
	elif drawer_tile != Vector2(-1, -1) and drawer_block_pointers[drawer_tile.x][drawer_tile.y] == null:
		remove_reference(block)
		block.reparent($DrawerBlocks)
		block.position = drawer_tile * 16
		block.on_board = false
		drawer_block_pointers[drawer_tile.x][drawer_tile.y] = block
		SFX.place()
	else:
		block.position = block.old_position
	
	update_all_hitboxes()

func try_process_block(block, left, right, up, down):
	var grid_x = block.position.x / 16
	var grid_y = block.position.y / 16
	match (block.get_type()):
		Operators.ADDITION:       return Operators.add(block, left, right, up, down)
		Operators.MULTIPLICATION: return Operators.multiply(block, left, right, up, down)
		Operators.SUBTRACTION:    return Operators.subtract(block, left, right)
		# cant happen on either edge of the board
		Operators.SWAPIFICATION:  return Operators.swap(block, left, right, queue_block_at) if grid_x != 0 and grid_x != board_width - 1 else false
		Operators.EQUALITY:       return Operators.eq(block, left, right, queue_block_at) if grid_x != 0 and grid_x != board_width - 1 else false
		Operators.GLYPH_EQUALITY: return Operators.glyph_eq(block, left, right, queue_block_at) if grid_x != 0 and grid_x != board_width - 1 else false
		Operators.GLYPH_SWAPIFICATION: return Operators.glyph_swap(block, left, right, queue_block_at) if grid_x != 0 and grid_x != board_width - 1 else false
		Operators.VERTICAL_SWAPIFICATION: return Operators.vertical_swap(block, up, down, queue_block_at) if grid_y != 0 and grid_y != board_height - 1 else false

	return false

"""
func create_blocks():
	var sorting_criterion = func(a, b):
		return a[0] < b[0]
		# basically sort the creation requests by position

	block_creation_queue.sort_custom(sorting_criterion)
	var last_seen_position := Vector2(-1, -1)
	var cumulative_total = 0

	for idx in range(len(block_creation_queue) + 1):
		if idx == len(block_creation_queue):
			# last element, flush last cumulative creation
			make_block_at(last_seen_position, cumulative_total % 10, true)
			get_block_at(last_seen_position).shine()
			continue

		var creation_request = block_creation_queue[idx]

		if last_seen_position == Vector2(-1, -1):
			# first request
			last_seen_position = creation_request[0]
			cumulative_total = creation_request[1]
		elif creation_request[0] == last_seen_position:
			# trying to create another block at this position!
			# just accumulate the values
			cumulative_total += creation_request[1]
		else:
			# finished accumulating and found a new block position
			# flush last cumulative creation
			make_block_at(last_seen_position, cumulative_total % 10, true)
			get_block_at(last_seen_position).shine()
			# get new position and totals
			last_seen_position = creation_request[0]
			cumulative_total = creation_request[1]
"""

func create_blocks():
	var zero_created = false
	for block in block_creation_queue:
		var existing_block = get_block_at(block[0])
		if existing_block != null:
			existing_block.add(block[1])
		else:
			make_block_at(block[0], block[1], true)
		get_block_at(block[0]).shine()
		if get_block_at(block[0]).get_type() == 0:
			zero_created = true
	return zero_created

func advance_stage():
	# apparently a prerelease reference
	# process operators
	var did_any_operations = false
	var zero_created = false
	var glyphs_destroyed = false

	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null or block.is_number(): continue

			var left = null if x == 0 else get_block_at(Vector2(x - 1, y))
			var right = null if x == board_width - 1 else get_block_at(Vector2(x + 1, y))
			var up = null if y == 0 else get_block_at(Vector2(x, y - 1))
			var down = null if y == board_height - 1 else get_block_at(Vector2(x, y + 1))

			did_any_operations = try_process_block(block, left, right, up, down) or did_any_operations

	# flush changes
	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null: continue
			
			if block.to_be_destroyed:
				block.queue_free()
				block_pointers[x][y] = null
	
	# create blocks
	if len(block_creation_queue) > 0:
		zero_created = create_blocks()
		block_creation_queue = []

	if zero_created:
		for x in range(board_width):
			for y in range(board_height):
				var block = block_pointers[x][y]
				if block == null: continue

				if block.get_type() == Operators.GLYPH_EQUALITY or block.get_type() == Operators.GLYPH_SWAPIFICATION:
					block.queue_free()
					block_pointers[x][y] = null
					glyphs_destroyed = true

	# flush changes
	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null: continue
			block.update_visuals()
	
	update_all_hitboxes()

	# sound effects
	if did_any_operations:
		SFX.operation()
	if glyphs_destroyed:
		SFX.glyph_destroy()

	if won():
		var playback_controls = get_node("../GUI/PlaybackControls")
		playback_controls.update_paused(true)
		await get_tree().create_timer(1).timeout
		Settings.level_index += 1
		playback_controls.update_playback_mode(false)
		reset()

func won() -> bool:
	for row in block_pointers:
		for block in row:
			if block != null and block.get_type() != 0:
				return false
	return true

func update_all_hitboxes():
	# loop through every block on the board and in the drawer
	# blocks with their front face obscured can only be picked up from the top
	# blocks WITHOUT their front face obscured can be picked up from there too

	for x in range(board_width):
		for y in range(board_height):
			var block = block_pointers[x][y]
			if block == null: continue
			if y == board_height - 1: 
				# if we're on the bottom of the board then obv the front face is clear
				block.is_front_obscured = false
				continue
			
			block.is_front_obscured = block_pointers[x][y + 1] != null
	
	for x in range(DRAWER_WIDTH):
		for y in range(DRAWER_HEIGHT):
			var block = drawer_block_pointers[x][y]
			if block == null: continue
			if y == DRAWER_HEIGHT - 1: 
				# if we're on the bottom of the board then obv the front face is clear
				block.is_front_obscured = false
				continue
			
			block.is_front_obscured = drawer_block_pointers[x][y + 1] != null
