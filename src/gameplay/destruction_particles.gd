extends Node2D

func _ready() -> void:
	$GPUParticles2D.emitting = true
	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(queue_free)