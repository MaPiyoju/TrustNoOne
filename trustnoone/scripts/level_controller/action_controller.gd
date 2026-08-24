extends CanvasLayer
class_name ActionController

signal btn_move_signal
signal btn_inspect_signal
signal btn_talk_signal
signal btn_use_item_signal
signal btn_end_signal

@onready var btn_move: Button = $MarginContainer/VBoxContainer/GridContainer/btnMove
@onready var btn_inspect: Button = $MarginContainer/VBoxContainer/GridContainer/btnInspect
@onready var btn_talk: Button = $MarginContainer/VBoxContainer/GridContainer/btnTalk
@onready var btn_use_item: Button = $MarginContainer/VBoxContainer/GridContainer/btnUseItem
@onready var btn_end: Button = $MarginContainer/VBoxContainer/btnEnd

func _ready() -> void:
	btn_move.disabled = true
	btn_inspect.disabled = true
	btn_talk.disabled = true
	btn_use_item.disabled = true
	btn_end.disabled = true

func enable_btns():
	btn_move.disabled = false
	btn_inspect.disabled = false
	#btn_talk	.disabled = false
	#btn_use_item.disabled = false
	btn_end.disabled = false
	
func disable_all():
	btn_move.disabled = true
	btn_inspect.disabled = true
	btn_talk	.disabled = true
	btn_use_item.disabled = true
	btn_end.disabled = true

func _on_btn_move_pressed() -> void:
	btn_move_signal.emit()

func _on_btn_inspect_pressed() -> void:
	btn_inspect_signal.emit()

func _on_btn_talk_pressed() -> void:
	btn_talk_signal.emit()

func _on_btn_use_item_pressed() -> void:
	btn_use_item_signal.emit()

func _on_btn_end_pressed() -> void:
	btn_end_signal.emit()
