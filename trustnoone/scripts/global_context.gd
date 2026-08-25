extends Node

var max_turns := 20
var current_turn := 20
var player: CharacterRes
var playerItems: Array[ItemRes]

var transition_scene = preload("res://scenes/levels/scene_transition.tscn")

func change_scene(target_scene_path: String) -> void:
	var transition_instance = transition_scene.instantiate()
	get_tree().root.add_child(transition_instance)
	
	# 1. Pone la pantalla en negro
	await transition_instance.fade_out()
	
	# 2. Cambia la escena activa
	var error = get_tree().change_scene_to_file(target_scene_path)
	if error != OK:
		push_error("Error al cargar la escena: %s" % target_scene_path)
		
	# 3. Revela la nueva escena y destruye la capa de transición
	await transition_instance.fade_in()
	transition_instance.queue_free()
