extends CanvasLayer
class_name CompleteSheet

signal character_setup()

@onready var sheet_1: SheetControl = $MarginContainer/VBoxContainer/Control
@onready var sheet_2: SheetControl = $MarginContainer/VBoxContainer/Control2
@onready var sheet_3: SheetControl = $MarginContainer/VBoxContainer/Control3
@onready var sheet_4: SheetControl = $MarginContainer/VBoxContainer/Control4

@export var npc_sprite_figure: Array[Sprite2D]

var sheets: Array[SheetControl]
var ordered_list: Array[CharacterRes]

var currentPlayer := 0

func setup_sheets(selected_character: CharacterRes, all_characters: Array[CharacterRes]) -> Array[CharacterRes]:
	ordered_list = []
	sheets = [sheet_1, sheet_2, sheet_3, sheet_4]
	if selected_character != null:
		ordered_list.append(selected_character)
	
	for character_res in all_characters:
		if character_res != selected_character and not ordered_list.has(character_res):
			ordered_list.append(character_res)
			
	for i in range(sheets.size()):
		if i < ordered_list.size() and sheets[i] != null:
			var character_res := ordered_list[i]
			var sheet_ui := sheets[i]
			
			sheet_ui.load_character_data(character_res)
			
			# Connect signal to refresh UI when stats change on this resource
			if not character_res.stat_changed.is_connected(_on_character_stat_changed):
				character_res.stat_changed.connect(_on_character_stat_changed)
			
			ordered_list[i].items = []
	
	set_start_player()
	
	character_setup.emit()
	
	return ordered_list

func set_start_player():
	var startPlayer = randi_range(0, ordered_list.size()-1)
	currentPlayer = startPlayer
	sheets[startPlayer].enable_turn(true)

func next_player():
	sheets[currentPlayer].enable_turn(false)
	currentPlayer = currentPlayer+1 if currentPlayer < sheets.size() - 1 else 0
	while(ordered_list[currentPlayer].isDead()):
		currentPlayer = currentPlayer+1 if currentPlayer < sheets.size() - 1 else 0
	
	sheets[currentPlayer].enable_turn(true)

func add_item(newItem: ItemRes):
	if(ordered_list[currentPlayer].items.size() < 4):
		ordered_list[currentPlayer].items.append(newItem)

func get_random_player(ignore: int, coords: Vector2i) -> int:
	var available_players := range(sheets.size()).filter(
		func(i):
			return i != ignore \
				and sheets[i].current_room == coords \
				and not ordered_list[i].isDead()
	)
		
	if available_players.is_empty():
		return -1

	return available_players.pick_random()

func _on_character_stat_changed(_stat: PropertyType.PropertyEnum, _new_value: int):
	if(ordered_list[0].aura == 0):
		GlobalContext.ending_type = 0
		GlobalContext.change_scene("res://scenes/levels/bad_ending.tscn")
	
	if(ordered_list[GlobalContext.traitor].aura == 0):
		GlobalContext.ending_type = 2
		GlobalContext.change_scene("res://scenes/levels/good_ending.tscn")
		
	for i in range(sheets.size()):
		#Regular player death
		if(ordered_list[i].aura == 0 && i != 0 && i != GlobalContext.traitor):
			sheets[i].dead_character()
		if i < ordered_list.size() and sheets[i] != null:
			sheets[i].load_character_data(ordered_list[i])
