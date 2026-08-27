extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var play_button: Button = $PlayButton

@export var char_speed: float = 0.035

const PLAY_SCENE := "res://scenes/levels/level_1.tscn"

var _waiting_for_input: bool = false

func _ready() -> void:
	play_button.disabled = true
	
	play_button.pressed.connect(_on_play_pressed)
	if GlobalContext.mission and not GlobalContext.mission.description_img.is_empty():
		sprite_2d.texture = load(GlobalContext.mission.description_img)
	
	var full_text: String = ""
	if GlobalContext.mission:
		full_text = GlobalContext.mission.description
	
	if not full_text.is_empty():
		start_narrative_typewriter(full_text)
	else:
		play_button.disabled = false

func _unhandled_input(event: InputEvent) -> void:
	# Check if the player presses Space / Accept while paused at a period
	if _waiting_for_input and event.is_action_pressed("ui_accept"):
		_waiting_for_input = false

func start_narrative_typewriter(text_to_display: String) -> void:
	rich_text_label.text = text_to_display
	rich_text_label.visible_characters = 0
	
	var total_chars: int = text_to_display.length()
	if total_chars == 0:
		play_button.disabled = false
		return
	
	var sentences: Array[String] = _split_by_sentences(text_to_display)
	
	var tween: Tween = create_tween()
	var current_char_count: int = 0
	
	for sentence in sentences:
		current_char_count += sentence.length()
		var duration: float = sentence.length() * char_speed
		
		tween.tween_property(rich_text_label, "visible_characters", current_char_count, duration)
		
		if sentence.ends_with("."):
			tween.tween_callback(func(): _waiting_for_input = true)
			tween.tween_property(self, "_waiting_for_input", false, 0.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func(): play_button.disabled = false)

func _split_by_sentences(raw_text: String) -> Array[String]:
	var result: Array[String] = []
	var parts: PackedStringArray = raw_text.split(".")
	
	for i in range(parts.size()):
		var part: String = parts[i]
		if i < parts.size() - 1:
			result.append(part + ".")
		elif not part.is_empty():
			result.append(part)
			
	return result
	
func _on_play_pressed() -> void:
	GlobalContext.change_scene(PLAY_SCENE)
