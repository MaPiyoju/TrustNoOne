extends Node

var max_turns := 20
var current_turn := 20
var player: CharacterRes
var playerItems: Array[ItemRes]
var mission: MissionRes
var startPlayer:=0
var isInHunt:= false
var traitor: int

const MISSIONS_PATH := "res://resources/missions/"

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
	
func select_random_mission() -> void:
	var dir := DirAccess.open(MISSIONS_PATH)
	if dir == null:
		push_error("No se pudo abrir la carpeta de misiones: " + MISSIONS_PATH)
		return
	var mission_files: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import"):
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				mission_files.append(MISSIONS_PATH + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if mission_files.is_empty():
		push_warning("No se encontraron misiones en: " + MISSIONS_PATH)
		return
	var random_path: String = mission_files.pick_random()
	mission = load(random_path) as MissionRes
	
func player_msg():
	if(!isInHunt):
		var rnd = randi_range(0, mission.allies_txt.size()-1)
		return mission.allies_txt[rnd]
	else:
		var rnd = randi_range(0, mission.traitor_txt.size()-1)
		return mission.traitor_txt[rnd]

func check_hunt() -> bool:
	if(isInHunt):
		pass
		
	if(max_turns - current_turn > mission.traitor_threshold):
		isInHunt = true
		traitor = randi_range(1,3)
		print("There is a traitor, ",traitor)
		
		return true
	else:
		return false

func check_escape():
	if(isInHunt):
		#Check good ending
		if(max_turns - mission.traitor_threshold - mission.survive_threshold > current_turn):
			print(max_turns - mission.traitor_threshold - mission.survive_threshold, " - ", current_turn)
			GlobalContext.change_scene("res://scenes/levels/good_ending.tscn")
