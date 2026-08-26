# TargetSelectionDialog.gd
extends CanvasLayer
class_name TargetSelectionDialog

signal target_selected(target_character: CharacterRes)

@onready var title_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/cancel

func setup(targets: Array[CharacterRes], item_name: String) -> void:
	title_label.text = "Select target for " + item_name + ":"
	
	# Clear previous grid items
	for child in grid_container.get_children():
		child.queue_free()
		
	# Populate the GridContainer with target buttons
	for target in targets:
		var btn := Button.new()
		btn.text = target.name
		btn.pressed.connect(func():
			target_selected.emit(target)
			queue_free()
		)
		grid_container.add_child(btn)
	
	if not cancel_button.pressed.is_connected(_on_cancel_pressed):
		cancel_button.pressed.connect(_on_cancel_pressed)

func _on_cancel_pressed() -> void:
	queue_free()
