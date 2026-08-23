extends Node2D
class_name CharacterController

@export var CharacterConfig: CharacterRes
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load():
	sprite_2d.texture = load(CharacterConfig.mini_figure)
