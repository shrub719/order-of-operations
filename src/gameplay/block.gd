class_name Block
extends Node2D

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
		$Outline.modulate = Color("92e8c0")

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

func is_mouse_over():
	var mouse = get_local_mouse_position()
	var bounds = Rect2(Vector2(0, -8), Vector2(16, 16))
	return bounds.has_point(mouse)

func _input(event: InputEvent) -> void:
	if is_mouse_over() and not locked and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			drag = true
			old_position = position
			z_index = 10
		elif event.is_released() and drag:
			drag = false
			# fuck signals man
			get_parent().get_parent().snap_block(self)
			z_index = 0

func _process(delta):
	if drag:
		var mouse = get_viewport().get_mouse_position()
		self.global_position = Vector2(mouse.x, mouse.y) - Vector2(8, 4)
