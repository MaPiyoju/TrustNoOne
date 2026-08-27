extends Node2D
class_name CharacterController

@export var CharacterConfig: CharacterRes
@export var isPlayer := false
@export var baseXOffset := 0.0
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var level_1: MainLevel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var speed: float = 50.0
var baseRoomDistance := Vector2(48,40)
var baseOffsetDistance: Vector2
var current_dir: Vector2 = Vector2.ZERO
var isMoving = false

func _ready() -> void:
	if(isPlayer):
		level_1 = $".."
		level_1.move_room.connect(move)
	else:
		global_position.x = baseXOffset
		baseOffsetDistance = global_position

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
	if !has_signal("die"):
		CharacterConfig.die.connect(die)
	
func move(newDir: Vector2i, character: CharacterRes):
	if(CharacterConfig == character):
		isMoving = true
		current_dir = baseRoomDistance * Vector2(newDir)

func move_npc(newDir: Vector2i, character: CharacterRes):
	if(CharacterConfig == character):
		isMoving = true
		var new_dir = baseRoomDistance * Vector2(newDir)
		new_dir = new_dir + baseOffsetDistance
		current_dir = new_dir

func die():
	animation_player.play("die")
