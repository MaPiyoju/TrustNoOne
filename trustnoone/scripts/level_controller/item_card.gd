extends TextureRect
class_name ItemCard

signal card_clicked(item_res: ItemRes)

var current_item: ItemRes
var is_enabled := true # Cambiado a true por defecto o sincronizado en _ready

func _ready() -> void:
	# Aplica la modulación inicial apenas el nodo entra al árbol de escena
	_update_visuals()

func setup(res: ItemRes, enabled: bool = true) -> void:
	current_item = res
	is_enabled = enabled
	
	if res != null:
		if res.item_pic != "" and ResourceLoader.exists(res.item_pic):
			texture = load(res.item_pic)
		else:
			texture = null
			
		var description_text := res.name
		
		if res.description != "":
			description_text += "\n" + res.description

		var effect_name: String = PropertyType.PropertyEnum.keys()[res.effect]
		description_text += "\n\nEfecto: %s (%+d)" % [
			effect_name.capitalize(),
			res.effect_value
		]
			
		tooltip_text = description_text
		position.y = 50
		
	_update_visuals()

func set_enabled(enabled: bool) -> void:
	position.y = 50 if !enabled else 0
	is_enabled = enabled
	_update_visuals()

func _update_visuals() -> void:
	if not is_inside_tree():
		return

	if is_enabled:
		modulate = Color(1, 1, 1, 1)
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		modulate = Color(0.4, 0.4, 0.4, 1)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _gui_input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if current_item != null:
				card_clicked.emit(current_item)
