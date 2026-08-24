extends Node2D
class_name RoomController

@export var RoomConfig: RoomRes
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func load():
	sprite_2d.texture = load(RoomConfig.texture)
