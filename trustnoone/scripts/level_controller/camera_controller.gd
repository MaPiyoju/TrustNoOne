class_name CameraController
extends Camera2D

var shake_strength := 0.0
var shake_duration := 0.0
var shake_time := 0.0

@export var shake_decay := 8.0
@export var target: Node2D
@export var return_duration := 0.2

var is_dragging := false
var drag_start_position := Vector2.ZERO

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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:

			if event.pressed:
				start_drag()
			else:
				end_drag()

	elif event is InputEventMouseMotion and is_dragging:
		global_position -= event.relative

func start_drag() -> void:
	is_dragging = true
	var player_position: Vector2 = target.global_position
	top_level = true
	global_position = player_position

func end_drag() -> void:
	is_dragging = false

	var target_position: Vector2 = target.global_position

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		return_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await tween.finished

	top_level = false
	position = Vector2.ZERO
