extends Control
class_name ScreenEffect

@onready var color_rect: ColorRect = $ColorRect

func show_damage() -> void:
	var shader_material := color_rect.material as ShaderMaterial
	shader_material.set_shader_parameter("intensity", 1.0)
	var tween := create_tween()
	tween.tween_method(
		func(value: float):
			shader_material.set_shader_parameter("intensity", value),
		1.0,
		0.0,
		0.5
	)
