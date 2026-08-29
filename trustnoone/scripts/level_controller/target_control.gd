extends Control
class_name TargetController

signal target_selected(target: int, item: ItemRes)
signal target_punch_selected(target: int)

@export var characterSheets: CompleteSheet
@onready var character_0: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_0
@onready var character_1: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_1
@onready var character_2: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/character_2

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var color_rect: ColorRect = $CanvasLayer/modal_blocker/ColorRect

var characters: Array[TextureRect]
var currentItem: ItemRes
var isPunch := false

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
		character_control.MOUSE_FILTER_IGNORE
		character_control.gui_input.connect(
			_on_character_clicked.bind(i)
		)
	
	canvas_layer.visible = false
	(color_rect as Control).MOUSE_FILTER_IGNORE

func setup_target():
	for i in range(characters.size()):
		characters[i].texture = load(characterSheets.ordered_list[i+1].profile_pic)
	
func enable_targets(item: ItemRes):
	currentItem = item
	enable_targets_base()

func enable_targets_punch():
	isPunch = true
	enable_targets_base()

func enable_targets_base():
	canvas_layer.visible = true
	(color_rect as Control).MOUSE_FILTER_STOP
	for i in range(characters.size()):
		var textures = characters[i].get_children()
		textures[1].visible = true
		characters[i].MOUSE_FILTER_IGNORE
		if(characterSheets.sheets[0].current_room == characterSheets.sheets[i+1].current_room):
			if(!characterSheets.ordered_list[i+1].isDead()):
				textures[1].visible = false
				characters[i].MOUSE_FILTER_STOP

func _on_character_clicked(event: InputEvent, idx: int) -> void:
	var textures = characters[idx].get_children()
	if(!textures[1].visible):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				canvas_layer.visible = false
				if(!isPunch):
					target_selected.emit(idx+1, currentItem)
				else:
					target_punch_selected.emit(idx+1)
				currentItem = null
				isPunch = false
