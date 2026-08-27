extends Control
class_name TargetController

signal target_selected(target: int, item: ItemRes)

@export var characterSheets: CompleteSheet
@onready var character_0: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_0
@onready var character_1: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_1
@onready var character_2: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_2

@onready var canvas_layer: CanvasLayer = $CanvasLayer

var characters: Array[TextureRect]
var currentItem: ItemRes

func _ready() -> void:
	if(characterSheets):
		characterSheets.character_setup.connect(setup_target)
	
	characters = [
		character_0,
		character_1,
		character_2
	]
	
	for i in range(characters.size()):
		var character_control = characters[i]
		character_control.gui_input.connect(
			_on_character_clicked.bind(i)
		)
	
	canvas_layer.visible = false

func setup_target():
	for i in range(characters.size()):
		characters[i].texture = load(characterSheets.ordered_list[i+1].profile_pic)
	
func enable_targets(item: ItemRes):
	currentItem = item
	canvas_layer.visible = true
	for i in range(characters.size()):
		var textures = characters[i].get_children()
		textures[1].visible = true
		if(characterSheets.sheets[0].current_room == characterSheets.sheets[i+1].current_room):
			if(!characterSheets.ordered_list[i+1].isDead()):
				textures[1].visible = false
		
func _on_character_clicked(event: InputEvent, idx: int) -> void:
	var textures = characters[idx].get_children()
	if(!textures[1].visible):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				canvas_layer.visible = false
				target_selected.emit(idx+1, currentItem)
