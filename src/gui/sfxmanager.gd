class_name SFXManager
extends Node

const INTERACT = preload("res://assets/sfx/interact.wav")
const INTERACT_LOCKED = preload("res://assets/sfx/interactLocked.wav")
const PLACE = preload("res://assets/sfx/place.wav")

const OPERATION_1 = preload("res://assets/sfx/operation.wav")
const OPERATION_2 = preload("res://assets/sfx/operationFast.wav")

const CLICK = preload("res://assets/sfx/click.wav")

const BOARD_ENTRY = preload("res://assets/sfx/boardEntry.wav")

const GLYPH_DESTROY = preload("res://assets/sfx/glyphDestroy.wav")
const GLYPH_DESTROY_2 = preload("res://assets/sfx/glyphDestroy2.wav")

func _ready():
	for i in range(16):
		var player = AudioStreamPlayer.new()
		add_child(player)

func play(stream, pitch_scale = 1.0):
	for player in get_children():
		if !player.playing:
			player.stream = stream
			player.pitch_scale = pitch_scale
			player.play()
			return

func interact(locked):
	var stream = INTERACT_LOCKED if locked else INTERACT
	play(stream)
	
func place():
	play(PLACE)

func operation():
	var stream = OPERATION_1 if randf() > 0.2 else OPERATION_2
	var pitch_scale = randf_range(0.5, 1.5)
	play(stream, pitch_scale)

func click(button):
	var stream = CLICK
	var pitch_scale = 1 - 0.05 * button
	play(stream, pitch_scale)

func board_entry():
	play(BOARD_ENTRY)

func glyph_destroy():
	play(GLYPH_DESTROY)
	play(GLYPH_DESTROY_2)


