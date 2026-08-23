extends Node2D
class_name MainLevel

signal move_room(dir: Vector2i)

@export var base_tiles: Array[RoomRes]
@export var characters: Array[CharacterRes]
@onready var character: CharacterController = $Character

@onready var up_arrow: DirectionArrow = $Character/Arrows/UpArrow
@onready var down_arrow: DirectionArrow = $Character/Arrows/DownArrow
@onready var right_arrow: DirectionArrow = $Character/Arrows/RightArrow
@onready var left_arrow: DirectionArrow = $Character/Arrows/LeftArrow

@onready var rooms_node: Node = $Rooms
var room_prefab: PackedScene

var rooms: Dictionary = {}
var currentRoom: Vector2i
var baseRoomDistance := Vector2(48,40)

func _ready() -> void:
	room_prefab = preload("res://scenes/room.tscn")
	
	var rndCharacter = randi_range(0,characters.size()-1)
	character.CharacterConfig = characters[rndCharacter]
	character.load()
	
	rooms[Vector2i(0, 0)] = base_tiles[0]
	currentRoom = Vector2i(0, 0)
	check_arrows(0)
	
	up_arrow.direction_changed.connect(explore_room)
	down_arrow.direction_changed.connect(explore_room)
	right_arrow.direction_changed.connect(explore_room)
	left_arrow.direction_changed.connect(explore_room)

func _process(delta: float) -> void:
	pass
	
func explore_room(newDir: Vector2i):
	var new_coordinates := currentRoom + newDir
	var available_rooms = base_tiles.filter(func(x:RoomRes): 
		return (rooms[currentRoom] as RoomRes).connections.has(x.connection_type)
	)
	var rnd_room = randi_range(0,available_rooms.size()-1)	
	if !rooms.has(new_coordinates):
		rooms[new_coordinates] = available_rooms[rnd_room]
		var newRoom = room_prefab.instantiate()
		rooms_node.add_child(newRoom)
		(newRoom as Node2D).position = Vector2(baseRoomDistance.x * new_coordinates.x, baseRoomDistance.y * new_coordinates.y)
		(newRoom as RoomController).RoomConfig = available_rooms[rnd_room]
		(newRoom as RoomController).load()
	
	check_arrows(0, true)
	
	currentRoom = new_coordinates
	move_room.emit(new_coordinates)
	
	await get_tree().create_timer(1.0).timeout
	check_arrows((rooms[new_coordinates] as RoomRes).connection_type)

func check_arrows(room_type: int, disable_all: bool = false):
	up_arrow.enable(false)
	down_arrow.enable(false)
	right_arrow.enable(false)
	left_arrow.enable(false)
	if(disable_all):
		return 

	match room_type:
		0:
			up_arrow.enable(true)
		1:
			down_arrow.enable(true)
		2:
			left_arrow.enable(true)
		3:
			right_arrow.enable(true)
		4:
			up_arrow.enable(true)
			left_arrow.enable(true)
		5:
			up_arrow.enable(true)
			right_arrow.enable(true)
		6:
			down_arrow.enable(true)
			right_arrow.enable(true)
		7:
			down_arrow.enable(true)
			left_arrow.enable(true)
		8:
			up_arrow.enable(true)
			down_arrow.enable(true)
			right_arrow.enable(true)
			left_arrow.enable(true)
		9:
			up_arrow.enable(true)
			down_arrow.enable(true)
		10:
			right_arrow.enable(true)
			left_arrow.enable(true)
