extends Node
const TEST_MISSION_RES := preload("res://resources/missions/mission_0.tres")

@onready var main_menu_button: Button = $MainMenuButton
@onready var credits_button: Button = $Credits
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

const SCENE_MAIN_MENU := "res://scenes/levels/main_menu.tscn"
const SCENE_CREDITS := "res://scenes/levels/credits.tscn"


@export var char_speed: float = 0.03


var _waiting_for_input: bool = false

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

	_set_buttons_disabled(true)
	
	if GlobalContext.mission == null:
		GlobalContext.mission = TEST_MISSION_RES
	if GlobalContext.mission and not GlobalContext.mission.good_ending_img.is_empty():
		match GlobalContext.ending_type:
			1:
				sprite_2d.texture = load(GlobalContext.mission.survive_ending_img)
			2:
				sprite_2d.texture = load(GlobalContext.mission.good_ending_img)
	
	var full_text: String = ""
	if GlobalContext.mission:
		match GlobalContext.ending_type:
			1:
				full_text = GlobalContext.mission.survive_ending_txt
			2:
				full_text = GlobalContext.mission.good_ending_txt

	if not full_text.is_empty():
		start_narrative_typewriter(full_text)
	else:
		_set_buttons_disabled(false)

func _unhandled_input(event: InputEvent) -> void:
	if _waiting_for_input and event.is_action_pressed("ui_accept"):
		_waiting_for_input = false

func start_narrative_typewriter(text_to_display: String) -> void:
	rich_text_label.text = text_to_display
	rich_text_label.visible_characters = 0
	
	var total_chars: int = text_to_display.length()
	if total_chars == 0:
		_set_buttons_disabled(false)
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

	tween.tween_callback(func(): _set_buttons_disabled(false))

func _set_buttons_disabled(disabled: bool) -> void:
	main_menu_button.disabled = disabled
	credits_button.disabled = disabled

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

func _on_main_menu_pressed() -> void:
	GlobalContext.change_scene(SCENE_MAIN_MENU)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_credits_pressed() -> void:
	GlobalContext.change_scene(SCENE_CREDITS)
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_main_menu_button_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)

func _on_credits_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.7)
