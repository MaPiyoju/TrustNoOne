extends Node

@onready var main_menu_button: Button = $MainMenuButton

const SCENE_MAIN_MENU := "res://scenes/levels/main_menu.tscn"

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed() -> void:
	GlobalContext.change_scene(SCENE_MAIN_MENU)
