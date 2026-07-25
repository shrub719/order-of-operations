extends VBoxContainer

var button_scene: PackedScene = preload("res://src/gui/level_button.tscn")

func _ready() -> void:
	# generate all level buttons
	for idx in range(len(Settings.level_order)):
		var button: LevelButton = button_scene.instantiate()
		button.text = str(idx + 1) + ". " + Settings.level_name_from_file(Settings.level_order[idx])
		button.level_idx = idx
		add_child(button)
