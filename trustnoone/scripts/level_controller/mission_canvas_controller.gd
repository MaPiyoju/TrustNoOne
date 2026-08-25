extends CanvasLayer
class_name MissionController

@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

func add_misssion_description(txt: String):
	rich_text_label.text= txt
