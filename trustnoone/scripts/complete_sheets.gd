
extends CanvasLayer

@onready var sheet_1: Control = $MarginContainer/VBoxContainer/Control
@onready var sheet_2: Control = $MarginContainer/VBoxContainer/Control2
@onready var sheet_3: Control = $MarginContainer/VBoxContainer/Control3
@onready var sheet_4: Control = $MarginContainer/VBoxContainer/Control4

func setup_sheets(selected_character: CharacterRes, all_characters: Array[CharacterRes]) -> void:
	var sheets: Array[Control] = [sheet_1, sheet_2, sheet_3, sheet_4]
	
	var ordered_list: Array[CharacterRes] = []
	if selected_character != null:
		ordered_list.append(selected_character)
	
	for character_res in all_characters:
		if character_res != selected_character and not ordered_list.has(character_res):
			ordered_list.append(character_res)
			
	for i in range(sheets.size()):
		if i < ordered_list.size() and sheets[i] != null:
			sheets[i].load_character_data(ordered_list[i])
