extends Sprite2D

@onready var SFX: SFXManager = $"/root/Sfxmanager"

var is_held_down := false

func is_mouse_over():
	var mouse = get_local_mouse_position()
	var bounds = Rect2(Vector2(0, 0), Vector2(32, 32))
	return bounds.has_point(mouse)

func _process(_delta: float) -> void:
	if is_mouse_over() and not is_held_down:
		frame = 1
	elif is_held_down:
		frame = 2
	else:
		frame = 0

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton: return

	var mouse_event = event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT: return

	var was_held_down = is_held_down
	is_held_down = mouse_event.is_pressed() and is_mouse_over()

	if not was_held_down and is_held_down:
		SFX.click(frame)
		get_node("/root/Transition").transition_to("res://src/gui/level_select.tscn")
