extends Node2D
class_name MainLevel

signal move_room(dir: Vector2i, character: CharacterRes)

@export var base_tiles: Array[RoomRes]
@export var characters: Array[CharacterRes]
@export var items: Array[ItemRes]
@export var events: Array[EventRes]
@onready var character: CharacterController = $Character

@onready var up_arrow: DirectionArrow = $Character/Arrows/UpArrow
@onready var down_arrow: DirectionArrow = $Character/Arrows/DownArrow
@onready var right_arrow: DirectionArrow = $Character/Arrows/RightArrow
@onready var left_arrow: DirectionArrow = $Character/Arrows/LeftArrow

@onready var dice: DiceController = $Character/Camera2D/Dice
@onready var log_canvas: LogController = $Character/LogCanvas
@onready var action_canvas: ActionController = $Character/ActionCanvas
@onready var game_info: GameInfoController = $Character/GameInfo
@onready var item_canvas: ItemController = $Character/ItemCanvas
@onready var mission_canvas: MissionController = $Character/MissionCanvas
@onready var screen_effect: ScreenEffect = $Character/ScreenEffect
@onready var target_control: Control = $Character/TargetControl

@onready var rooms_node: Node = $Rooms

@onready var character_sheets: CompleteSheet = $Character/CharacterSheets
@onready var npc_1: CharacterController = $NPC/NPC_1
@onready var npc_2: CharacterController = $NPC/NPC_2
@onready var npc_3: CharacterController = $NPC/NPC_3
var npcs : Array[CharacterController]

var room_prefab: PackedScene

var rooms: Dictionary = {}
var currentRoom: Vector2i
var playerCurrentRoom: Vector2i
var baseRoomDistance := Vector2(48,40)

@export var player_test: CharacterRes
var currSpeed: int
var isInEvent := false

@export var mision_test: MissionRes

func _ready() -> void:
	if(GlobalContext.mission == null):
		GlobalContext.mission = mision_test
	
	mission_canvas.add_misssion_description(GlobalContext.mission.description)
	npcs = [npc_1, npc_2, npc_3]
	room_prefab = preload("res://scenes/components/room.tscn")	
	
	rooms[Vector2i(0, 0)] = base_tiles[0]
	currentRoom = Vector2i(0, 0)
	playerCurrentRoom = Vector2i(0, 0)
	action_canvas.disable_all()

	var active_player: CharacterRes = GlobalContext.player
	if active_player == null:
		active_player = player_test if player_test != null else characters[0]
		GlobalContext.player = active_player
		
	character.CharacterConfig = active_player
	character.load()
	
	if character_sheets != null and character_sheets.has_method("setup_sheets"):
		var npcBaseList = character_sheets.setup_sheets(active_player, characters)
		npcs[0].CharacterConfig = npcBaseList[1]
		npcs[1].CharacterConfig = character_sheets.ordered_list[2]
		npcs[2].CharacterConfig = character_sheets.ordered_list[3]
		
		for npc in npcs:
			npc.load()
		
	next_player_turn(true)
	action_canvas.enable_hunt(false)
	
	if GlobalContext.player != null:
		character.CharacterConfig = GlobalContext.player
	elif player_test != null:
		character.CharacterConfig = player_test
	else:
		character.CharacterConfig = characters[0]
		
	character.load()
	
	up_arrow.direction_changed.connect(explore_room)
	down_arrow.direction_changed.connect(explore_room)
	right_arrow.direction_changed.connect(explore_room)
	left_arrow.direction_changed.connect(explore_room)
	
	dice.dice_ended.connect(validate_event)
	dice.dice_punch_ended.connect(validate_punch)
	dice.next.connect(enable_next_action)
	
	target_control.target_punch_selected.connect(check_punch)
	
	action_canvas.btn_move_signal.connect(move_action)
	action_canvas.btn_inspect_signal.connect(inspect_action)
	action_canvas.btn_talk_signal.connect(talk_action)
	action_canvas.btn_use_item_signal.connect(use_item_action)
	action_canvas.btn_end_signal.connect(end_action)
	action_canvas.btn_punch_signal.connect(punch_action)
	
	game_info.update_actions(character.CharacterConfig.speed, currSpeed)
	game_info.update_turns(true)
	
func explore_room(newDir: Vector2i):
	var new_coordinates := currentRoom + newDir
	var available_rooms = base_tiles.filter(func(x:RoomRes): 
		return (rooms[currentRoom] as RoomRes).connections.has(x.connection_type)
	)
	var rnd_room = randi_range(0,available_rooms.size()-1)
	var isTrigger = false
	var newEvent = null
	if !rooms.has(new_coordinates):
		rooms[new_coordinates] = available_rooms[rnd_room]
		var newRoom = room_prefab.instantiate()
		rooms_node.add_child(newRoom)
		(newRoom as Node2D).position = Vector2(baseRoomDistance.x * new_coordinates.x, baseRoomDistance.y * new_coordinates.y)
		set_room(new_coordinates)
		(newRoom as RoomController).RoomConfig = rooms[new_coordinates]
		
		match (newRoom as RoomController).RoomConfig.room_type:
			RoomType.RoomEnum.ITEM:
				isTrigger = false
			RoomType.RoomEnum.EVENT:
				isTrigger = true
				var rnd = randi_range(0, events.size()-1)
				newEvent = events[rnd]

		(newRoom as RoomController).load()	
	
	currentRoom = new_coordinates
	log_room_event(newEvent)#Log room and set event
	
	#Enable actions if there is no event happening
	if(!isTrigger && currSpeed > 0):
		#Player
		if(check_if_player()):
			action_canvas.enable_btns()
	else:
		action_canvas.disable_all()
		
	if(check_if_player()):
		check_arrows(0, true)
		playerCurrentRoom = new_coordinates
		move_room.emit(new_coordinates, current_player())
		if(!isTrigger):
			perform_action(check_if_player())
	
	character_sheets.sheets[character_sheets.currentPlayer].current_room = new_coordinates

func set_room(room_coord: Vector2i):
	var room_type = randi_range(0, 3)
	var item_threshold = randf_range(0, 1)
	(rooms[room_coord] as RoomRes).coordinates = room_coord
	(rooms[room_coord] as RoomRes).room_type = room_type as RoomType.RoomEnum
	(rooms[room_coord] as RoomRes).room_threshold = item_threshold
	
	var item_rnd = randi_range(0, items.size()-1)
	if(item_threshold > items[item_rnd].threshold):
		(rooms[room_coord] as RoomRes).item = items[item_rnd]

func check_arrows(room_type: int, disable_all: bool = false, isPlayer: bool = true):
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
	
	if(!isPlayer):
		var npcDir = [up_arrow, down_arrow, right_arrow, left_arrow]
		var available_dirs = npcDir.filter(func(x:DirectionArrow): 
			return x.visible
		)
		var newNpcDir = randi_range(0, available_dirs.size()-1)
		move_npc(available_dirs[newNpcDir].type)
		
		up_arrow.enable(false)
		down_arrow.enable(false)
		right_arrow.enable(false)
		left_arrow.enable(false)

func validate_event(dice_value: int, isPlayer: bool):
	var curEvent = dice.currentEvent
	if(curEvent.effect_value > 0):#Positive effect
		if(dice_value > curEvent.threshold):
			character_sheets.ordered_list[character_sheets.currentPlayer].modify_stat(curEvent.effect,curEvent.effect_value)
			log_canvas.add_log(dice.badActionEvent)
		else:
			log_canvas.add_log(dice.goodActionEvent)
	else:
		if(dice_value < curEvent.threshold):
			log_canvas.add_log(dice.badActionEvent)
			character_sheets.ordered_list[character_sheets.currentPlayer].modify_stat(curEvent.effect,curEvent.effect_value)
			var viewport := get_viewport()
			if viewport:
				var camera := viewport.get_camera_2d() as CameraController
				if camera:
					camera.shake(15.0, 0.25)
		else:
			log_canvas.add_log(dice.goodActionEvent)
	
	await get_tree().create_timer(1.5).timeout
	isInEvent = false
	
	perform_action(isPlayer)

func log_room_event(event: EventRes):
	var newLog = dice.set_regular(rooms[currentRoom],current_player(), check_if_player())
	log_canvas.add_log("- "+newLog)
	if(event):
		isInEvent = true
		dice.set_event(event, current_player(), character_sheets.currentPlayer == 0)

func enable_next_action():
	if(character_sheets.currentPlayer == 0):#Player next action
		if(currSpeed > 0):
			action_canvas.enable_btns()
		else:
			next_player_turn()
	else:#NPC action turn
		if(currSpeed > 0):
			npc_action_turn()

func move_action(isPlayer: bool = true):
	check_arrows((rooms[currentRoom] as RoomRes).connection_type, false, isPlayer)
	if(!isPlayer):
		perform_action(isPlayer)

func punch_action(isPlayer: bool = true):
	var target: int = character_sheets.get_random_player(character_sheets.currentPlayer, character_sheets.sheets[character_sheets.currentPlayer].current_room)
	var current = character_sheets.currentPlayer
	
	log_canvas.add_log(character_sheets.ordered_list[current].name + "is trying to land a punch ")
	await get_tree().create_timer(0.5).timeout
	
	if target < 0:
		log_canvas.add_log("[color=#FF6B6B]No valid targets![/color]")
		if(!isPlayer):
			perform_action(isPlayer)
		return

	if(current == 0):
		(target_control as TargetController).enable_targets_punch()
	else:
		check_punch(target)

func check_punch(target: int):
	var diceMsg = "You need to throw more than " if character_sheets.currentPlayer == 0 else current_player().name + " needs to throw more than "
	diceMsg += str(character_sheets.ordered_list[target].strength) + " to connect a punch into " + character_sheets.ordered_list[target].name +"'s face"
	dice.set_punch_dice(diceMsg, character_sheets.currentPlayer == 0, target)

func validate_punch(dice_value: int, isPlayer: bool, target: int):
	item_canvas.validate_punch(dice_value > character_sheets.ordered_list[target].strength, character_sheets.currentPlayer, target)
	await get_tree().create_timer(1).timeout
	perform_action(isPlayer)

func inspect_action(isPlayer: bool = true):
	var itemUser = "You " if check_if_player() else current_player().name
	log_canvas.add_log(
		"[color=#38B764]" + itemUser + "[/color] check the [color=#FFCD75]" +
		(rooms[currentRoom] as RoomRes).name + "[/color]"
	)
	await get_tree().create_timer(0.5).timeout
	if (rooms[currentRoom] as RoomRes).item == null:
		log_canvas.add_log("There's nothing in this room")
	else:
		if current_player().items.size() < 4:
			var item = (rooms[currentRoom] as RoomRes).item
			# El item se agrega al personaje cuyo turno está activo
			character_sheets.add_item(item)
			# Solo actualizamos el inventario visual si es el jugador
			if isPlayer:
				GlobalContext.playerItems = current_player().items
				item_canvas.render_items(current_player().items)
				await get_tree().create_timer(0.5).timeout
				item_canvas.set_items_enabled(false)
				
			log_canvas.add_log(
				"[color=#38B764]" + itemUser + "[/color] found: [color=#FFCD75]" +
				item.name + "[/color]"
			)
			(rooms[currentRoom] as RoomRes).item = null
		else:
			log_canvas.add_log(
				"[color=#38B764]" + itemUser +
				"[/color] can't hold any more items"
			)
	perform_action(isPlayer)

func talk_action(isPlayer: bool = true):
	#Implement dialogic as well
	var currentCoords = character_sheets.sheets[character_sheets.currentPlayer].current_room
	var roomPlayers = []
	for i in range(character_sheets.sheets.size()):
		if i != character_sheets.currentPlayer && character_sheets.sheets[i].current_room == currentCoords:
			roomPlayers.append(character_sheets.ordered_list[i])

	var nameColor = "38B764" if !GlobalContext.isInHunt else "A73E53"
	if(roomPlayers.size() > 0):
		for roomPlayer in roomPlayers:
			if(roomPlayer.aura == 0):
				log_canvas.add_log("[color=#"+nameColor+"]"+roomPlayer.name+"[/color] says: [color=#FFCD75]"+GlobalContext.mission.dead_txt+"[/color]")
			else:
				log_canvas.add_log("[color=#"+nameColor+"]"+roomPlayer.name+"[/color] says: [color=#FFCD75]"+GlobalContext.player_msg()+"[/color]")
	else:
		log_canvas.add_log("There's no one to talk with here" if isPlayer else current_player().name + " tried talking to the walls - Got no response")
	
	if(!isPlayer):
		perform_action(isPlayer)
	
func use_item_action(isPlayer: bool = true) -> void:
	if isPlayer:
		if GlobalContext.playerItems.size() == 0:
			log_canvas.add_log("You have no items to use!")
		elif item_canvas.can_use_items():
			item_canvas.set_items_enabled(true)
			log_canvas.add_log("Select an item from your hand below.")
		else:
			log_canvas.add_log("You have no action points left to use items!")
	else:
		var current_char = current_player()
		log_canvas.add_log(current_char.name + " is trying to use an item")
		if current_char.items.size() > 0:
			item_canvas.set_items_enabled(false)
			item_canvas.use_item_by_index(0)
			await get_tree().create_timer(1.5).timeout
			perform_action(isPlayer)
		else:
			log_canvas.add_log(current_char.name + " has no items to use.")
			perform_action(isPlayer)

func end_action():
	if(check_if_player()):
		action_canvas.disable_all()
		log_canvas.add_log("You ended your turn")
	else:
		log_canvas.add_log(current_player().name + " ended their turn")
	next_player_turn()

func perform_action(isPlayer):
	if(isInEvent):
		return
		
	currSpeed-=1
	game_info.update_actions(current_player().speed, currSpeed)
	
	if(currSpeed < 1):
		action_canvas.disable_all()
		await get_tree().create_timer(1.5).timeout
		end_action()
	else:
		if(!isPlayer):
			await get_tree().create_timer(1).timeout
			dice.enable_next()
		else:
			enable_next_action()

func npc_action_turn():
	if(GlobalContext.traitor == character_sheets.currentPlayer):#Traitor
		var currentCoords = character_sheets.sheets[character_sheets.currentPlayer].current_room
		var rdnIdx = character_sheets.get_random_player(character_sheets.currentPlayer,currentCoords)
		if(rdnIdx > -1):
			character_sheets.ordered_list[rdnIdx].modify_stat(PropertyType.PropertyEnum.AURA,-1)
			if(rdnIdx == 0):
				log_canvas.add_log("[color=#A73E53]Ouch, you've been damaged, be careful who you trust[/color]")
				screen_effect.show_damage()
			else:
				log_canvas.add_log("[color=#A73E53]Someone has been hurt, be careful with the people in the house[/color]")
			
			var viewport := get_viewport()
			if viewport:
				var camera := viewport.get_camera_2d() as CameraController
				if camera:
					camera.shake(15.0, 0.25)
			
			perform_action(false)
		else:
			var rndAction = randi_range(0,2)
			match rndAction:
				0:
					move_action(false)
				1:
					inspect_action(false)
				2:
					talk_action(false)
	else:#Ally
		var rnd = randf_range(0,1)
		if(rnd < 0.1):
			end_action()
		else:
			#Avoid use item if NPC has no items
			var rndAction = randi_range(0,(4 if GlobalContext.isInHunt else 3))
			match rndAction:
				0:
					move_action(false)
				1:
					inspect_action(false)
				2:
					use_item_action(false)
				3:
					use_item_action(false)
				4:
					punch_action(false)

func next_player_turn(first_turn: bool = false):
	if(!first_turn):
		character_sheets.next_player()
		if(GlobalContext.startPlayer == character_sheets.currentPlayer):
			game_info.update_turns()
			if(!GlobalContext.isInHunt):
				if(GlobalContext.check_hunt()):
					AudioManager.stop_music()
					action_canvas.enable_hunt(true)
					AudioManager.play_sfx(load("res://assets/audio/scream.ogg"),0.7)
					log_canvas.add_log("[color=#A73E53]"+GlobalContext.mission.traitor_excuse+"[/color]")
					AudioManager.play_music(load("res://assets/audio/trusnoone_pursuit.wav"),false)
					await get_tree().create_timer(3).timeout
					AudioManager.set_play_rnd(["res://assets/audio/trusnoone_pursuit.wav"],40)
					var newMission = "Choose between: \n\n~Find and [color=#A73E53]kill the ?? traitor[/color]"
					newMission += "\n~Hide and survive for [color=#ffcc75]"+str(GlobalContext.mission.survive_threshold)+" turns from now on[/color]"
					mission_canvas.add_misssion_description(newMission, true)
	else:
		GlobalContext.startPlayer = character_sheets.currentPlayer
		
	action_canvas.disable_all()
	check_arrows(0,true)
	
	if(check_if_player()):
		dice.change_btn(true)
		currSpeed = character.CharacterConfig.speed
		game_info.update_actions(character.CharacterConfig.speed, currSpeed)
		dice.set_msg("Select your action above")
		log_canvas.add_log("Your turn: ")
		currentRoom = playerCurrentRoom
		action_canvas.enable_btns()
		item_canvas.set_items_enabled(false)
	else:
		dice.change_btn(false)
		currSpeed = current_player().speed	
		game_info.update_actions(currSpeed, currSpeed)
		currentRoom = character_sheets.sheets[character_sheets.currentPlayer].current_room
		log_canvas.add_log(current_player().name + "'s turn: ")
		item_canvas.set_items_enabled(false)
		if(!GlobalContext.isInHunt):
			move_action(false)
		else:
			npc_action_turn()

func move_npc(dir: Vector2i):
	explore_room(dir)
	npcs[character_sheets.currentPlayer-1].move_npc(currentRoom, current_player())

func check_if_player()-> bool:
	return character_sheets.currentPlayer == 0
	
func current_player()->CharacterRes:
	return character_sheets.ordered_list[character_sheets.currentPlayer]
