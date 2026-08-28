extends CanvasLayer

@onready var control: Control = $Control
@onready var resume_button: Button = $Control/PanelContainer/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $Control/PanelContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Control/PanelContainer/VBoxContainer/QuitButton

const SCENE_MAIN_MENU := "res://scenes/levels/main_menu.tscn"

func _ready() -> void:
	# Hide pause menu UI on start
	control.hide()
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var is_paused: bool = !get_tree().paused
	get_tree().paused = is_paused
	
	if is_paused:
		control.show()
		resume_button.grab_focus()
	else:
		control.hide()

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GlobalContext.change_scene(SCENE_MAIN_MENU)

func _on_quit_pressed() -> void:
	get_tree().quit()
