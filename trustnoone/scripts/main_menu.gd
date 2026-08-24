extends Control

func _ready() -> void:
	# Conexión por código (opcional si prefieres no usar el panel de Señales)
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed() -> void:
	# Transición hacia la selección de personajes
	GlobalContext.change_scene("res://scenes/characters/character_selection.tscn")

func _on_exit_pressed() -> void:
	# Cierra el juego
	get_tree().quit()
