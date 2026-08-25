extends Node

@onready var main_menu_button: Button = $MainMenuButton
@onready var credits_button: Button = $CreditsButton

const SCENE_MAIN_MENU := "res://scenes/levels/main_menu.tscn"
const SCENE_CREDITS := "res://scenes/levels/credits.tscn"

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

func _on_main_menu_pressed() -> void:
	GlobalContext.change_scene(SCENE_MAIN_MENU)

func _on_credits_pressed() -> void:
	GlobalContext.change_scene(SCENE_CREDITS)
