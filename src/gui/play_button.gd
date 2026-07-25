extends TextureButton

func _on_button_down() -> void:
	get_node("/root/Transition").transition_to("res://src/gui/level_select.tscn")