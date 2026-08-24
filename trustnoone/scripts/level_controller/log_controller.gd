extends CanvasLayer
class_name LogController

@onready var rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel

func add_log(txt: String):
	if(rich_text_label.text == ""):
		rich_text_label.text += "\n"+txt
	else:
		rich_text_label.text += "\n\n"+txt
