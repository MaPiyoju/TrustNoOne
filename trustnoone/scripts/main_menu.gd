extends Node

@onready var play_button: Button = $CanvasLayer/VBoxContainer/PlayButton
@onready var exit_button: Button = $CanvasLayer/VBoxContainer/ExitButton
@onready var credits_button: Button = $CanvasLayer/VBoxContainer/CreditsButton
@onready var scene_transition: SceneTransition = $SceneTransition

const SCENE_CHARACTER_SELECT := "res://scenes/characters/character_selection.tscn"
const SCENE_CREDITS := "res://scenes/levels/credits.tscn"
func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	
	scene_transition.set_modulate(1.0)
	await get_tree().create_timer(1.0).timeout
	scene_transition.fade_in()

func _on_play_pressed() -> void:
	GlobalContext.change_scene(SCENE_CHARACTER_SELECT)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)
func _on_credits_pressed() -> void:
	GlobalContext.change_scene(SCENE_CREDITS)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)
		
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_play_button_mouse_entered() -> void:
	GlobalContext.reset_game()
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)

func _on_credits_button_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)

func _on_exit_button_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)
