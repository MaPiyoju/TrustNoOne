extends CanvasLayer
class_name  CompleteSheet

@onready var sheet_1: SheetControl = $MarginContainer/VBoxContainer/Control
@onready var sheet_2: SheetControl = $MarginContainer/VBoxContainer/Control2
@onready var sheet_3: SheetControl = $MarginContainer/VBoxContainer/Control3
@onready var sheet_4: SheetControl = $MarginContainer/VBoxContainer/Control4

@export var npc_sprite_figure: Array[Sprite2D]

var sheets: Array[SheetControl]
var ordered_list: Array[CharacterRes]

var currentPlayer := 0

func setup_sheets(selected_character: CharacterRes, all_characters: Array[CharacterRes]) -> Array[CharacterRes]:
	sheets = [sheet_1, sheet_2, sheet_3, sheet_4]
	if selected_character != null:
		ordered_list.append(selected_character)
	
	for character_res in all_characters:
		if character_res != selected_character and not ordered_list.has(character_res):
			ordered_list.append(character_res)
			
	for i in range(sheets.size()):
		if i < ordered_list.size() and sheets[i] != null:
			sheets[i].load_character_data(ordered_list[i])
	
	set_start_player()
	
	return ordered_list

func set_start_player():
	var startPlayer = randi_range(0, ordered_list.size()-1)
	currentPlayer = startPlayer
	sheets[startPlayer].enable_turn(true)

func next_player():
	sheets[currentPlayer].enable_turn(false)
	currentPlayer = currentPlayer+1 if currentPlayer < sheets.size() - 1 else 0
	for i in range(sheets.size()):
		if(i != currentPlayer):
			sheets[currentPlayer].enable_turn(true)

func add_item(newItem: ItemRes):
	if(ordered_list[currentPlayer].items.size() < 4):#4 items max
		ordered_list[currentPlayer].items.append(newItem)
