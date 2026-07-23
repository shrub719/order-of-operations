class_name Block
extends Node2D

var locked := false
var to_be_destroyed := false
var next_state := 0

func update_visuals():
	# TODO: if next_state is -1 then do a cool animation
	$Sprite2D.frame = next_state
	$LockedIndicator.visible = locked and $Sprite2D.frame >= 10

	if next_state != 0:
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
