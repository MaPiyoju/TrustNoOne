extends CanvasLayer
class_name ItemController

signal item_used(item_res: ItemRes)

@onready var item_hand: HBoxContainer = $MarginContainer/HBoxContainer
var card_scene: PackedScene = preload("res://scenes/components/item_card.tscn")

var main_level: MainLevel
var items_enabled := false

func _ready() -> void:
	main_level = get_tree().current_scene as MainLevel
	if not main_level:
		print("Warning: Could not find MainLevel")

func render_items(items_list: Array[ItemRes]) -> void:
	if item_hand == null:
		return
		
	for child in item_hand.get_children():
		child.queue_free()
		
	var count: int = mini(items_list.size(), 4)

	for i in range(count):
		var item_res: ItemRes = items_list[i]
		var card_instance = card_scene.instantiate()
		
		item_hand.add_child(card_instance)
		
		if card_instance.has_method("setup"):
			card_instance.setup(item_res)
			
		if card_instance.has_method("set_enabled"):
			card_instance.set_enabled(items_enabled)
			
		if card_instance.has_signal("card_clicked"):
			card_instance.card_clicked.connect(_on_card_clicked)
			
		if main_level.target_control.has_signal("target_selected"):
			(main_level.target_control as TargetController).target_selected.connect(affect_target)
			
		if main_level.dice.has_signal("dice_item_ended"):
			(main_level.dice as DiceController).dice_item_ended.connect(complete_dice_item)

func add_item(item_res: ItemRes) -> void:
	var current_char = main_level.current_player()
	render_items(current_char.items)

func _on_card_clicked(item_res: ItemRes) -> void:
	use_item(item_res)

func use_item(item_res: ItemRes) -> void:
	var current_char = main_level.current_player()
	var char_index = main_level.character_sheets.currentPlayer
	
	if !items_enabled && char_index == 0:
		return
	if not main_level:
		push_error("MainLevel reference not set")
		return
	
	#Disable items to enforce use of actions again 
	set_items_enabled(false)
	
	# 1. Requirements Validation
	if current_char.knowledge < item_res.min_knowledge:
		if(char_index == 0):
			main_level.log_canvas.add_log("[color=#FF6B6B]Not enough knowledge to use " + item_res.name + "![/color]")
		else:
			main_level.log_canvas.add_log(current_char.name + "[color=#FF6B6B] doesn't have enough knowledge to use " + item_res.name + "![/color]")
		return
	
	# 2. Dice Check Condition
	if item_res.dice_condition > 0:
		var diceMsg = "Yoy need to throw a " if char_index == 0 else current_char.name + " needs to throw a "
		diceMsg += str(item_res.dice_condition) + " to use the " + item_res.name
		main_level.dice.set_item_dice(diceMsg, char_index == 0, item_res)
		return
	
	# 3. Resolve Target Characters
	var targets: Array[CharacterRes] = _get_target_characters(item_res.target_type, char_index)
	if targets.is_empty():
		main_level.log_canvas.add_log("[color=#FF6B6B]No valid targets for " + item_res.name + "![/color]")
		return

	# 4. If player Select target
	if(char_index == 0):
		if(item_res.effect_value < 0):
			(main_level.target_control as TargetController).enable_targets(item_res)
			return
	
	# 4. Apply Effect across Targets
	var applied_any := false
	for target in targets:
		var target_idx = main_level.character_sheets.ordered_list.find(target)
		if _apply_stat_effect(item_res, target, target_idx):
			applied_any = true

	if applied_any:
		_consume_item_and_action(current_char, item_res)
		item_used.emit(item_res)

func affect_target(idx: int, item: ItemRes):
	var applied_any := false
	if _apply_stat_effect(item, main_level.character_sheets.ordered_list[idx], idx):
		applied_any = true

	if applied_any:
		_consume_item_and_action(main_level.current_player(), item)
		item_used.emit(item)

func complete_dice_item(dice_value: int, isPlayer: bool, item: ItemRes):
	var applied_any := false
	if _apply_stat_effect(item, main_level.character_sheets.ordered_list[main_level.character_sheets.currentPlayer], main_level.character_sheets.currentPlayer):
		applied_any = true
		 
	if dice_value < item.dice_condition:
		var nameDice = "You " if isPlayer else main_level.current_player().name
		main_level.log_canvas.add_log("[color=#FF6B6B]"+nameDice+" failed (" + str(dice_value) + "/" + str(item.dice_condition) + ")! " + item.name + " wasted.[/color]")
	
	if applied_any:
		_consume_item_and_action(main_level.current_player(), item)
		item_used.emit(item)

func _consume_item_and_action(character: CharacterRes, item_res: ItemRes) -> void:
	character.items.erase(item_res)

	if main_level.check_if_player():
		GlobalContext.playerItems = character.items

	# 1. Renderizar la nueva lista de tarjetas
	render_items(character.items)

	# 2. Forzar la desactivación visual y lógica de las tarjetas restantes
	set_items_enabled(false)

	main_level.currSpeed -= 1
	main_level.game_info.update_actions(character.speed, main_level.currSpeed)

	if main_level.currSpeed < 1:
		main_level.action_canvas.disable_all()
		await main_level.get_tree().create_timer(1.0).timeout
		main_level.end_action()
	else:
		if main_level.check_if_player():
			main_level.action_canvas.enable_btns()

func _apply_stat_effect(item_res: ItemRes, target: CharacterRes, target_idx: int) -> bool:
	var stat_type: PropertyType.PropertyEnum = item_res.effect
	var old_val: int = _get_stat_value(target, stat_type)

	target.modify_stat(stat_type, item_res.effect_value)

	var new_val: int = _get_stat_value(target, stat_type)

	var stat_name := _stat_enum_to_string(stat_type)
	var color := "#38B764" if item_res.effect_value >= 0 else "#FF6B6B"

	main_level.log_canvas.add_log(
		"[color=#FFCD75]" + item_res.name + "[/color] applied to " +
		target.name + "! " +
		stat_name + ": " + str(old_val) +
		" → [color=" + color + "]" + str(new_val) + "[/color]"
	)

	if item_res.effect_value < 0:
		var viewport := main_level.get_viewport()
		if viewport:
			var camera := viewport.get_camera_2d() as CameraController
			if camera:
				camera.shake(8.0, 0.2)

	return true

func _get_target_characters(target_type: TargetType.TargetEnum, current_idx: int) -> Array[CharacterRes]:
	var result: Array[CharacterRes] = []
	var sheets = main_level.character_sheets
	var current_room = sheets.sheets[current_idx].current_room
	
	match target_type:
		TargetType.TargetEnum.SELF:
			result.append(sheets.ordered_list[current_idx])
			
		TargetType.TargetEnum.SINGLE_TARGET:
			# Target first non-self character in the room (or self if alone)
			for i in range(sheets.sheets.size()):
				if i != current_idx and sheets.sheets[i].current_room == current_room:
					result.append(sheets.ordered_list[i])
					break
				
		TargetType.TargetEnum.ALL_IN_ROOM:
			for i in range(sheets.sheets.size()):
				if sheets.sheets[i].current_room == current_room && !sheets.ordered_list[i].isDead():
					result.append(sheets.ordered_list[i])
					
		TargetType.TargetEnum.ALL_PLAYERS:
			for character in sheets.ordered_list:
				result.append(character)
				
	return result

func _get_stat_value(character: CharacterRes, stat: PropertyType.PropertyEnum) -> int:
	match stat:
		PropertyType.PropertyEnum.AURA:
			return character.aura
		PropertyType.PropertyEnum.KNOWLEDGE:
			return character.knowledge
		PropertyType.PropertyEnum.SPEED:
			return character.speed
		PropertyType.PropertyEnum.STRENGTH:
			return character.strength
		_:
			return 0

func _stat_enum_to_string(stat: PropertyType.PropertyEnum) -> String:
	match stat:
		PropertyType.PropertyEnum.AURA: return "Aura"
		PropertyType.PropertyEnum.KNOWLEDGE: return "Knowledge"
		PropertyType.PropertyEnum.SPEED: return "Speed"
		PropertyType.PropertyEnum.STRENGTH: return "Strength"
		_: return "Unknown"

func can_use_items() -> bool:
	if not main_level:
		return false
		
	var current_char = main_level.current_player()
	var has_items := GlobalContext.playerItems.size() > 0
	var has_speed := main_level.currSpeed > 0
	
	return has_speed and has_items

func use_item_by_index(index: int) -> void:
	var items = main_level.current_player().items
	if index >= 0 and index < items.size():
		use_item(items[index])
		
func set_items_enabled(enabled: bool) -> void:
	items_enabled = enabled

	if item_hand == null:
		return

	for card in item_hand.get_children():
		if card.has_method("set_enabled"):
			card.set_enabled(enabled)
