extends Node
class_name PlayerController

@export var player_characters: Array[CharacterRes] = []

signal character_updated(index: int, character: CharacterRes)
signal character_died(index: int, character: CharacterRes)

func _ready() -> void:
	for i in range(player_characters.size()):
		var char_res = player_characters[i]
		if char_res:
			char_res.stats_changed.connect(_on_character_changed.bind(i, char_res))
			char_res.died.connect(_on_character_died.bind(i, char_res))

func change_stat(character_index: int, stat: PropertyType.PropertyEnum, amount: int) -> void:
	if character_index >= 0 and character_index < player_characters.size():
		var target: CharacterRes = player_characters[character_index]
		if target:
			target.modify_stat(stat, amount)

func _on_character_changed(index: int, character: CharacterRes) -> void:
	character_updated.emit(index, character)

func _on_character_died(index: int, character: CharacterRes) -> void:
	character_died.emit(index, character)
