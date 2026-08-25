extends Control
class_name SheetControl

@onready var character_sprite: TextureRect = $character
@onready var aura: RichTextLabel = $aura
@onready var strenght: RichTextLabel = $strenght
@onready var knowledge: RichTextLabel = $knowledge
@onready var speed: RichTextLabel = $speed
@onready var disable_screen: ColorRect = $DisableScreen

var current_room: Vector2i

func _ready() -> void:
	enable_turn(false)

func load_character_data(res: CharacterRes) -> void:
	if res == null:
		return
		
	if res.profile_pic != "" and ResourceLoader.exists(res.profile_pic):
		character_sprite.texture = load(res.profile_pic)
	else:
		character_sprite.texture = null
		
	# Asignar textos con valores reales del Resource
	aura.text = "aur: %d" % res.aura
	strenght.text = "str: %d" % res.strenght
	knowledge.text = "knw: %d" % res.knowledge
	speed.text = "spd: %d" % res.speed

func enable_turn(_enable: bool):
	disable_screen.visible = !_enable
