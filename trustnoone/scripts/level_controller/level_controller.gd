extends Node2D
class_name MainLevel

signal move_room(dir: Vector2i)

@export var base_tiles: Array[RoomRes]
@export var characters: Array[CharacterRes]
@export var items: Array[ItemRes]
@export var events: Array[EventRes]
@onready var character: CharacterController = $Character

@onready var up_arrow: DirectionArrow = $Character/Arrows/UpArrow
@onready var down_arrow: DirectionArrow = $Character/Arrows/DownArrow
@onready var right_arrow: DirectionArrow = $Character/Arrows/RightArrow
@onready var left_arrow: DirectionArrow = $Character/Arrows/LeftArrow

@onready var dice: DiceController = $Character/Dice
@onready var log_canvas: LogController = $Character/LogCanvas
@onready var action_canvas: ActionController = $Character/ActionCanvas
@onready var game_info: GameInfoController = $Character/GameInfo

@onready var rooms_node: Node = $Rooms
var room_prefab: PackedScene

var rooms: Dictionary = {}
var currentRoom: Vector2i
var baseRoomDistance := Vector2(48,40)

@export var player_test: CharacterRes
var currSpeed: int

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
	
	dice.dice_ended.connect(validate_event)
	
	action_canvas.btn_move_signal.connect(move_action)
	action_canvas.btn_inspect_signal.connect(inspect_action)
	action_canvas.btn_talk_signal.connect(talk_action)
	action_canvas.btn_use_item_signal.connect(use_item_action)
	action_canvas.btn_end_signal.connect(end_action)
	
	GlobalContext.player = player_test
	currSpeed = GlobalContext.player.speed
	game_info.update_actions(GlobalContext.player.speed, currSpeed)
	game_info.update_turns()

func _process(delta: float) -> void:
	pass
	
func explore_room(newDir: Vector2i):
	var new_coordinates := currentRoom + newDir
	var available_rooms = base_tiles.filter(func(x:RoomRes): 
		return (rooms[currentRoom] as RoomRes).connections.has(x.connection_type)
	)
	var rnd_room = randi_range(0,available_rooms.size()-1)
	var isTrigger = false
	if !rooms.has(new_coordinates):
		rooms[new_coordinates] = available_rooms[rnd_room]
		var newRoom = room_prefab.instantiate()
		rooms_node.add_child(newRoom)
		(newRoom as Node2D).position = Vector2(baseRoomDistance.x * new_coordinates.x, baseRoomDistance.y * new_coordinates.y)
		set_room(new_coordinates)
		(newRoom as RoomController).RoomConfig = rooms[new_coordinates]
		
		match (newRoom as RoomController).RoomConfig.room_type:
			RoomType.RoomEnum.REGULAR:
				pass
			RoomType.RoomEnum.ITEM:
				isTrigger = false
			RoomType.RoomEnum.EVENT:
				isTrigger = true
				var rnd = randi_range(0, events.size()-1)
				dice.set_event(events[rnd])

		(newRoom as RoomController).load()
	
	check_arrows(0, true)
	
	currentRoom = new_coordinates
	move_room.emit(new_coordinates)
	
	if(!isTrigger && currSpeed > 0):
		action_canvas.enable_btns()
	else:
		action_canvas.disable_all()

func set_room(room_coord: Vector2i):
	var room_type = randi_range(0, 3)
	var item_threshold = randf_range(0, 1)
	(rooms[room_coord] as RoomRes).coordinates = room_coord
	(rooms[room_coord] as RoomRes).room_type = room_type as RoomType.RoomEnum
	(rooms[room_coord] as RoomRes).room_threshold = item_threshold
	
	var item_rnd = randi_range(0, items.size()-1)
	if(item_threshold > items[item_rnd].threshold):
		(rooms[room_coord] as RoomRes).item = items[item_rnd]

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

func validate_event(dice_value: int):
	var curEvent = dice.currentEvent
	if(dice_value > curEvent.threshold):
		log_canvas.add_log(curEvent.good_action)
	else:
		var newLog = curEvent.bad_action.replace("{0}", "[color=#B13E53]"+str(curEvent.effect_value)+"[/color]")
		newLog = newLog.replace("{1}", "[color=#FFCD75]"+PropertyType.PropertyEnum.find_key(curEvent.effect)+"[/color]")
		log_canvas.add_log(newLog)
	
	enable_next_turn()
		
func enable_next_turn():
	dice.hide_dice()
	if(currSpeed > 0):
		action_canvas.enable_btns()
	#await get_tree().create_timer(1.0).timeout
	
func move_action():
	check_arrows((rooms[currentRoom] as RoomRes).connection_type)
	perform_action()
	
func inspect_action():
	if((rooms[currentRoom] as RoomRes).item == null):
		log_canvas.add_log("There's nothing in this room")
	else:
		log_canvas.add_log("You've found: [color=#FFCD75]"+(rooms[currentRoom] as RoomRes).item.name+"[/color]")
	
	perform_action()
	
func talk_action():
	pass
	
func use_item_action():
	pass
	
func end_action():
	pass
	
func perform_action():
	currSpeed-=1
	game_info.update_actions(GlobalContext.player.speed, currSpeed)
	if(currSpeed < 1):
		action_canvas.disable_all()
