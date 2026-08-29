extends CanvasLayer
class_name MissionController

@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var animation_player: AnimationPlayer = $MarginContainer/AnimationPlayer
@onready var music_btn: TextureButton = $music_btn

func add_misssion_description(txt: String, animate: bool = false):
	rich_text_label.text= txt
	if(animate):
		animation_player.play("buzz")

func _on_music_btn_pressed() -> void:
	GlobalContext.isMuted = !GlobalContext.isMuted
	AudioManager.set_mute(GlobalContext.isMuted)
	
	if(GlobalContext.isMuted):
		music_btn.texture_normal = load("res://assets/sprites/menu/Music_1.png")
	else:
		music_btn.texture_normal = load("res://assets/sprites/menu/Music_0.png")
