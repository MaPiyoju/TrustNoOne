extends Node

@onready var play_button: Button = $CanvasLayer/VBoxContainer/PlayButton
@onready var exit_button: Button = $CanvasLayer/VBoxContainer/ExitButton
@onready var scene_transition: SceneTransition = $SceneTransition

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	scene_transition.set_modulate(1.0)
	await get_tree().create_timer(1.0).timeout
	scene_transition.fade_in()

func _on_play_pressed() -> void:
	GlobalContext.change_scene("res://scenes/characters/character_selection.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
