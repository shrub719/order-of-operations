extends Node2D

func set_title(name: String):
	var title = "[wave amp=10.0 freq=2.5 connected=1]" + name + "[/wave]"
	get_node("GUI/Title/TitleText").text = title

func set_description(text: String):
	var description = "[wave amp=10.0 freq=2.5 connected=1]" + text + "[/wave]"
	if text == "":
		get_node("GUI/Title/Description").visible = false
	else:
		get_node("GUI/Title/Description").text = description
		get_node("GUI/Title/Description").visible = true