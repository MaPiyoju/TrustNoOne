extends CanvasLayer
class_name MissionController

@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var animation_player: AnimationPlayer = $MarginContainer/AnimationPlayer

func add_misssion_description(txt: String, animate: bool = false):
	rich_text_label.text= txt
	if(animate):
		animation_player.play("buzz")
