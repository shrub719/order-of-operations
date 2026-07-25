extends CanvasLayer

const TRANSITION_TIME = 0.5
signal transition_complete

var sprite: Sprite2D = Sprite2D.new()
var scene_change_to = null
var transition_phase = TransitionPhase.NONE
var scene_changeless_mode = false
var timer = 0

func _ready():
	layer = 5
	add_child(sprite)
	sprite.centered = false
	sprite.position.x = -480
	sprite.texture = load("res://assets/transition.png")
	sprite.z_index = 100

func _process(delta: float) -> void:
	if transition_phase == TransitionPhase.FADING_IN:
		timer += delta
		sprite.position.x = lerp(-480, -80, min(timer / TRANSITION_TIME, 1))

		if timer >= TRANSITION_TIME:
			# switch scenes!
			if not scene_changeless_mode: get_tree().change_scene_to_file(scene_change_to)
			else: transition_complete.emit() 
			transition_phase = TransitionPhase.FADING_OUT
			timer = 0
	elif transition_phase == TransitionPhase.FADING_OUT:
		timer += delta
		sprite.position.x = lerp(-80, 320, min(timer / TRANSITION_TIME, 1))

		if timer >= TRANSITION_TIME:
			# hide
			sprite.position.x = -480
			transition_phase = TransitionPhase.NONE
			scene_change_to = null
			timer = 0

func transition_to(path):
	scene_changeless_mode = false
	scene_change_to = path
	transition_phase = TransitionPhase.FADING_IN
	timer = 0

func transition_without_scene_change():
	scene_changeless_mode = true
	transition_phase = TransitionPhase.FADING_IN
	timer = 0

enum TransitionPhase {
	FADING_IN,
	FADING_OUT,
	NONE
}