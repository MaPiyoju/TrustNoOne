extends CanvasLayer
class_name ItemController

signal item_used(item_res: ItemRes)


@onready var item_hand: HBoxContainer = $MarginContainer/HBoxContainer


var card_scene: PackedScene = preload("res://scenes/components/item_card.tscn")

func render_items(items_list: Array[ItemRes]) -> void:
	if item_hand == null:
		return
		
	for child in item_hand.get_children():
		child.queue_free()
		
	var count: int = mini(items_list.size(), 4)

	for i in range(count):
		var item_res: ItemRes = items_list[i]
		var card_instance = card_scene.instantiate()
		
		item_hand.add_child(card_instance)
		
		if card_instance.has_method("setup"):
			card_instance.setup(item_res)
			
		if card_instance.has_signal("card_clicked"):
			card_instance.card_clicked.connect(_on_card_clicked)

func _on_card_clicked(item_res: ItemRes) -> void:
	item_used.emit(item_res)

func add_item(item: ItemRes):
	render_items(GlobalContext.playerItems)
	print (GlobalContext.playerItems.size())
	print("llega aca")
