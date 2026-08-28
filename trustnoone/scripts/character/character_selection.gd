extends Control

# Exporta un Array para arrastrar tus recursos (.tres) desde el inspector
@export var characters: Array[CharacterRes] = []

@onready var id_card: Control = $ID
@onready var character_texture: TextureRect = $ID/character
@onready var rich_text_label: RichTextLabel = $ID/RichTextLabel

var current_index: int = 0
var is_animating: bool = false
var default_position: Vector2

func _ready() -> void:
	default_position = id_card.position
	
	if characters.size() > 0:
		update_card_info(characters[current_index])
	$Right.pressed.connect(_on_right_pressed)
	$Left.pressed.connect(_on_left_pressed)
	$SelectCharacterButton.pressed.connect(_on_select_pressed)

func update_card_info(res: CharacterRes) -> void:
	if res.profile_pic != "":
		character_texture.texture = load(res.profile_pic)
	
	rich_text_label.text = "[b]NAME:[/b] %s\n" % res.name
	rich_text_label.text += "[b]AGE:[/b] %d\n" % res.age
	rich_text_label.text += "[b]STATS:[/b]\n"
	rich_text_label.text += "  AURA: %d\n" % res.aura
	rich_text_label.text += "  KNOWLEDGE: %d\n" % res.knowledge
	rich_text_label.text += "  STRENGTH: %d\n" % res.strength
	rich_text_label.text += "  SPEED: %d\n" % res.speed
	rich_text_label.text += "[b]DESCRIPTION:[/b] %s" % res.description

func change_character(direction: int) -> void:
	if is_animating or characters.is_empty():
		return
		
	is_animating = true
	var next_index = (current_index + direction) % characters.size()
	if next_index < 0:
		next_index = characters.size() - 1
		
	var offset_x = get_viewport_rect().size.x # Distancia del desplazamiento
	var exit_pos = default_position + Vector2(-direction * offset_x, 0)
	var enter_pos = default_position + Vector2(direction * offset_x, 0)

	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(id_card, "position", exit_pos, 0.25)
	tween.tween_property(id_card, "modulate:a", 0.0, 0.25)
	
	await tween.finished

	current_index = next_index
	update_card_info(characters[current_index])
	id_card.position = enter_pos
	
	var tween_in = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween_in.tween_property(id_card, "position", default_position, 0.25)
	tween_in.tween_property(id_card, "modulate:a", 1.0, 0.25)
	
	await tween_in.finished
	is_animating = false

func _on_right_pressed() -> void:
	change_character(1)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_left_pressed() -> void:
	change_character(-1)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_select_pressed() -> void:
	if not characters.is_empty():
		GlobalContext.select_random_mission()
		GlobalContext.player = characters[current_index]
		GlobalContext.change_scene("res://scenes/levels/mission_cinematic.tscn")

	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)	
	

func _on_select_character_button_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)
