extends CanvasLayer

@onready var character_sprite: Sprite2D = $character
@onready var aura: RichTextLabel = $aura
@onready var strenght: RichTextLabel = $strenght
@onready var knowledge: RichTextLabel = $knowledge
@onready var speed: RichTextLabel = $speed

var characters: Dictionary = {
	"1": preload("res://assets/sprites/characters/bluecharacter.png"),
	"2": preload("res://assets/sprites/characters/greencharacter.png"),
	"3": preload("res://assets/sprites/characters/purplecharacter.png"),
	"4": preload("res://assets/sprites/characters/yellowcharacter.png"),
}

func _ready() -> void:
	# Test with character "1" (aura, strength, knowledge, speed)
	load_character("1", 80, 15, 10, 20)

func load_character(id: String, aura_val: int, strength_val: int, knowledge_val: int, speed_val: int) -> void:
	if characters.has(id):
		character_sprite.texture = characters[id]
		aura.text = str(aura_val)
		strenght.text = str(strength_val)
		knowledge.text = str(knowledge_val)
		speed.text = str(speed_val)
	else:
		push_warning("Character ID not found: " + id)
