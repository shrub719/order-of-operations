extends Sprite2D

var counter := 0.0

func _process(delta: float) -> void:
	counter += delta
	position.y = 4 * sin(counter)