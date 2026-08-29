extends Node2D
class_name DiceController

signal dice_ended(dice_value: int, isPlayer: bool)
signal dice_item_ended(dice_value: int, isPlayer: bool, item: ItemRes)
signal dice_punch_ended(dice_value: int, isPlayer: bool, target: int)
signal next()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var event_canvas: CanvasLayer = $EventCanvas
@onready var rich_text_label: RichTextLabel = $EventCanvas/MarginContainer/VBoxContainer/RichTextLabel
@onready var btn_throw: Button = $EventCanvas/MarginContainer/VBoxContainer/BtnThrow


const MAX_THROWS = 20

var currentEvent: EventRes
var isThrowing := false
var lastThrow := 0.0
var currentThrows = 0

var goodActionEvent := ""
var badActionEvent := ""

var isDice = true
var currentItem: ItemRes
var punchTarget = -1

var diceSfx: AudioStream

func _ready() -> void:
	btn_throw.disabled = true
	rich_text_label.text = ""
	visible = false
	diceSfx = load("res://assets/audio/dice.ogg")

func _process(delta: float) -> void:
	if(isThrowing):
		if(currentThrows < MAX_THROWS):
			var currentTime = Time.get_ticks_msec() / 1000.0
			if(currentTime - lastThrow > 0.05):
				throw()
		else:
			if(currentItem):
				dice_item_ended.emit(sprite_2d.frame+1, isDice, currentItem)
			elif(punchTarget > -1):
				dice_punch_ended.emit(sprite_2d.frame+1, isDice, punchTarget)
			else:
				dice_ended.emit(sprite_2d.frame+1, isDice)
			currentItem = null
			punchTarget = -1
			isThrowing = false
			
			await get_tree().create_timer(1.5).timeout
			hide_dice()

func set_event(event: EventRes, character: CharacterRes, isPlayer: bool):
	currentEvent = event
	
	var subjectName = character.name + " " if !isPlayer else "You "
	
	goodActionEvent = currentEvent.good_action.replace("{0}", "[color=#4f5277]"+subjectName+"[/color]")
	
	badActionEvent = currentEvent.bad_action.replace("{0}", "[color=#4f5277]"+subjectName+"[/color]")
	badActionEvent = badActionEvent.replace("{1}", "[color=#B13E53]"+str(currentEvent.effect_value)+"[/color]")
	badActionEvent = badActionEvent.replace("{2}", "[color=#FFCD75]"+PropertyType.PropertyEnum.find_key(currentEvent.effect)+"[/color]")
	
	var newTxt = event.description.replace("{0}", "[color=#38B764]"+str(event.threshold)+"[/color]")
	newTxt = newTxt.replace("{1}", "[color=#B13E53]"+str(event.effect_value)+"[/color]")
	newTxt = newTxt.replace("{2}", "[color=#FFCD75]"+PropertyType.PropertyEnum.find_key(event.effect)+"[/color]")
	rich_text_label.text = newTxt
	if(isPlayer):
		btn_throw.disabled = false
	else:
		btn_throw.disabled = true
		await get_tree().create_timer(1).timeout
		new_throw()

func set_regular(room: RoomRes, character: CharacterRes, isPlayer: bool) -> String:
	var newTxt = character.name + " has " if !isPlayer else "You've "
	newTxt += "entered the [color=#FFCD75]" + room.name + "[/color]"
	rich_text_label.text = newTxt
	
	if(!isPlayer):
		btn_throw.disabled = false
		
	return newTxt

func set_item_dice(msg: String, isPlayer: bool, item: ItemRes):
	currentItem = item
	rich_text_label.text = msg
	if(isPlayer):
		btn_throw.disabled = false
	else:
		btn_throw.disabled = true
		await get_tree().create_timer(1).timeout
		new_throw()

func set_punch_dice(msg: String, isPlayer: bool, target: int):
	punchTarget = target
	rich_text_label.text = msg
	if(isPlayer):
		btn_throw.disabled = false
	else:
		btn_throw.disabled = true
		await get_tree().create_timer(1).timeout
		new_throw()

func set_msg(msg:String):
	rich_text_label.text = msg

func hide_dice():
	btn_throw.disabled = true
	sprite_2d.visible = false

func new_throw():
	AudioManager.play_sfx(diceSfx,0.4)
	currentThrows = 0
	visible = true
	animation_player.play("throw")
	throw()
	
func throw():
	currentThrows+=1
	isThrowing = true
	lastThrow = Time.get_ticks_msec() / 1000.0
	var n = randi_range(0,6)
	sprite_2d.visible = true
	sprite_2d.frame = n

func change_btn(isPlayer: bool):
	isDice = isPlayer
	btn_throw.text = "THROW DICE" if isDice else "NEXT ACTION"
	btn_throw.disabled = true

func enable_next():
	btn_throw.disabled = false

func _on_btn_throw_pressed() -> void:
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)
	if(isDice):
		new_throw()
	else:
		next.emit()
		
	btn_throw.disabled = true

func _on_btn_throw_mouse_entered() -> void:
	if(!btn_throw.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)
