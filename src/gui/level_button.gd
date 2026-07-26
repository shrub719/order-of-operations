class_name LevelButton
extends Button

var level_idx = null
var been_pressed := false

func _on_button_down() -> void:
	if been_pressed: return
	been_pressed = true
	Settings.level_index = level_idx
	get_node("/root/Sfxmanager").click(level_idx % 5)
	get_node("/root/Transition").transition_to("res://src/gameplay/game_scene.tscn")