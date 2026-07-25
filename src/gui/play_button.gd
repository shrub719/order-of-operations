extends TextureButton

var been_pressed := false

func _on_button_down() -> void:
	if been_pressed: return
	been_pressed = true
	get_node("/root/Sfxmanager").click(0)
	get_node("/root/Transition").transition_to("res://src/gui/level_select.tscn")