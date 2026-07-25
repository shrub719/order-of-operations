class_name LevelButton
extends Button

var level_idx = null

func _on_button_down() -> void:
	Settings.level_index = level_idx
	get_node("/root/Transition").transition_to("res://src/gameplay/game_scene.tscn")