extends Node2D


@export var base_tiles: Array[RoomRes]
@export var characters: Array[CharacterRes]
@onready var character: CharacterController = $Character

var rooms: Dictionary = {}
var currentRoom: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rndCharacter = randi_range(0,characters.size()-1)
	character.CharacterConfig = characters[rndCharacter]
	character.load()
	
	rooms[Vector2i(0, 0)] = base_tiles[0]
	currentRoom = Vector2i(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func explore_room(newDir: Vector2i):
	var new_coordinates := currentRoom + newDir
	var available_rooms = base_tiles.filter(func(x:RoomRes): 
		return (rooms[currentRoom] as RoomRes).connections.has(x.connection_type)
	)
	var rnd_room = randi_range(0,available_rooms.size()-1)
	rooms[new_coordinates] = available_rooms[rnd_room]
	
	currentRoom = new_coordinates
