extends Node2D

func set_title(name: String):
	var title = "[wave amp=10.0 freq=2.5 connected=1]" + name + "[/wave]"
	get_node("GUI/Title/TitleText").text = title
