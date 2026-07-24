class_name SFXManager
extends AudioStreamPlayer

const INTERACT = preload("res://assets/sfx/interact.wav")
const INTERACT_LOCKED = preload("res://assets/sfx/interactLocked.wav")
const PLACE = preload("res://assets/sfx/place.wav")

const OPERATION_1 = preload("res://assets/sfx/operation.wav")
const OPERATION_2 = preload("res://assets/sfx/operationFast.wav")

func interact(locked):
	stream = INTERACT_LOCKED if locked else INTERACT
	play()
	
func place():
	stream = PLACE
	play()

func operation():
	stream = OPERATION_1 if randf() > 0.2 else OPERATION_2
	pitch_scale = randf_range(0.5, 1.5)
	play()
