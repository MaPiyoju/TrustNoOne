extends TextureRect
class_name ItemCard

signal card_clicked(item_res: ItemRes)

var current_item: ItemRes

func setup(res: ItemRes) -> void:
	current_item = res
	if res == null:
		return
		
	if res.item_pic != "" and ResourceLoader.exists(res.item_pic):
		texture = load(res.item_pic)
	else:
		texture = null
		
	var description_text := res.name
	if res.description != "":
		description_text += "\n" + res.description
	if res.effect != "":
		description_text += "\n\nEfecto: %s (%s)" % [res.effect, res.effect_value]
		
	tooltip_text = description_text

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_item != null:
			card_clicked.emit(current_item)
