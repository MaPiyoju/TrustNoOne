extends Area2D
class_name DirectionArrow

signal direction_changed(type: Vector2i)

@export var type: Vector2i

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_sprite_clicked()

func _on_sprite_clicked() -> void:
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)
	emit_signal("direction_changed", type)
	
func enable(value: bool):
	visible = value
