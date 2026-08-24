class_name CameraController
extends Camera2D

var shake_strength := 0.0
var shake_duration := 0.0
var shake_time := 0.0

@export var shake_decay := 8.0

func _process(delta: float) -> void:
	if shake_time > 0.0:
		shake_time -= delta

		var intensity = shake_strength * (shake_time / shake_duration)

		offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
	else:
		offset = Vector2.ZERO

func shake(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_duration = duration
	shake_time = duration
