extends Node2D
class_name CharacterController

@export var CharacterConfig: CharacterRes
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var level_1: MainLevel = $".."

var speed: float = 50.0
var baseRoomDistance := Vector2(48,40)
var current_dir: Vector2 = Vector2.ZERO
var isMoving = false

func _ready() -> void:
	level_1.move_room.connect(move)


func _process(delta: float) -> void:
	if isMoving:
		position = position.move_toward(
			current_dir,
			speed * delta
		)

		if position == current_dir:
			isMoving = false

	
func load():
	sprite_2d.texture = load(CharacterConfig.mini_figure)
	
func move(newDir: Vector2i):
	isMoving = true
	current_dir = baseRoomDistance * Vector2(newDir)
