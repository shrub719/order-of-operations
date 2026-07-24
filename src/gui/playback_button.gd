class_name PlaybackButton
extends Sprite2D

signal clicked

var is_held_down := false

func is_mouse_over():
	var mouse = get_local_mouse_position()
	var bounds = Rect2(Vector2(0, 0), Vector2(16, 22))
	return bounds.has_point(mouse)

func _process(_delta: float) -> void:
	if is_mouse_over() and not is_held_down:
		get_node("Shine").color.a = 0.2
	else:
		get_node("Shine").color.a = 0

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton: return

	var mouse_event = event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT: return

	var was_held_down = is_held_down
	is_held_down = mouse_event.is_pressed() and is_mouse_over()
	frame_coords.y = 1 if is_held_down else 0

	if not was_held_down and is_held_down:
		# just clicked, emit a signal
		clicked.emit()