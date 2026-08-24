extends Node2D
class_name DiceController

signal dice_ended(dice_value: int)

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

func _ready() -> void:
	btn_throw.disabled = true
	rich_text_label.text = ""
	visible = false

func _process(delta: float) -> void:
	if(isThrowing):
		if(currentThrows < MAX_THROWS):
			var currentTime = Time.get_ticks_msec() / 1000.0
			if(currentTime - lastThrow > 0.05):
				throw()
		else:
			isThrowing = false
			dice_ended.emit(sprite_2d.frame+1)

func set_event(event: EventRes):
	currentEvent = event
	var newTxt = event.description.replace("{0}", "[color=#38B764]"+str(event.threshold)+"[/color]")
	newTxt = newTxt.replace("{1}", "[color=#B13E53]"+str(event.effect_value)+"[/color]")
	newTxt = newTxt.replace("{2}", "[color=#FFCD75]"+PropertyType.PropertyEnum.find_key(event.effect)+"[/color]")
	print(newTxt)
	rich_text_label.text = newTxt
	btn_throw.disabled = false
	
	var viewport := get_viewport()
	if viewport:
		var camera := viewport.get_camera_2d() as CameraController
		if camera:
			camera.shake(15.0, 0.25)

func hide_dice():
	btn_throw.disabled = true
	sprite_2d.visible = false

func new_throw():
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

func _on_btn_throw_pressed() -> void:
	new_throw()
	btn_throw.disabled = true
