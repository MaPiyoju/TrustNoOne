extends CanvasLayer
class_name SceneTransition

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

# Rutas de escenas centralizadas
const SCENE_MAIN_MENU := "res://scenes/main_menu.tscn"
const SCENE_CHARACTER_SELECT := "res://scenes/character_selection.tscn"
const SCENE_GAME := "res://scenes/level_1.tscn"

func _ready() -> void:
	color_rect.modulate.a = 0.0

func set_modulate(modulate: float):
	color_rect.modulate.a = modulate

## Transición a negro (Salida)
func fade_out() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("fade_to_black")
	await animation_player.animation_finished

## Revelar pantalla (Entrada)
func fade_in() -> void:
	animation_player.play("fade_to_normal")
	await animation_player.animation_finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
