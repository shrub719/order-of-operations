class_name Block
extends Node2D
@onready var SFX: SFXManager = $"/root/Sfxmanager"

var locked := false
var on_board := false
var to_be_destroyed := false
var next_type := 0

func update_visuals():
	# TODO: if next_type is -1 then do a cool animation
	$Sprite2D.frame = next_type
	$LockedIndicator.visible = locked and is_operator()

	# maybe only have it glow if it's the last block? otherwise the outline looks weird
	if next_type != 0:
		$Outline.modulate = Color("14182e")
	else:
		$Outline.modulate = Color("ffffff")

func is_number():
	return $Sprite2D.frame <= 9

func is_operator():
	return not is_number()

func get_type():
	return $Sprite2D.frame

func destroy():
	to_be_destroyed = true

func get_grid_position():
	return position / 16

var drag := false
var old_position = Vector2(0, 0)
var is_front_obscured := false

func is_mouse_over():
	var mouse = get_local_mouse_position()
	var bounds = Rect2(Vector2(0, -6), Vector2(16, 16))
	if not is_front_obscured:
		# include front face
		bounds = Rect2(Vector2(0, -6), Vector2(16, 22))
	return bounds.has_point(mouse)

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_RIGHT and Settings.level() == "playground" and is_mouse_over():
		self.queue_free()
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not is_mouse_over(): 
		return

	if event.is_pressed() and Settings.can_drag_blocks and not locked:
		drag = true
		old_position = position
		z_index = 10
		SFX.interact(false)
	elif event.is_pressed():
		SFX.interact(true)
	elif event.is_released() and drag:
		drag = false
		# fuck signals man
		get_parent().get_parent().snap_block(self)
		z_index = 0

func _process(_delta):
	if drag and Settings.can_drag_blocks:
		var mouse = get_viewport().get_mouse_position()
		self.global_position = Vector2(mouse.x, mouse.y) - Vector2(8, 4)

func encode():
	var data := BlockData.new()
	data.is_locked = locked
	data.type = $Sprite2D.frame
	return data

func add(n):
	$Sprite2D.frame = ($Sprite2D.frame + n) % 10
	next_type = $Sprite2D.frame

func shine():
	$AnimationPlayer.play("shine")

class BlockData:
	# enough information to recreate a block 
	var is_locked := false
	var type := 0
