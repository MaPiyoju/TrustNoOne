extends CanvasLayer
class_name ActionController

signal btn_move_signal
signal btn_inspect_signal
signal btn_talk_signal
signal btn_use_item_signal
signal btn_end_signal
signal btn_punch_signal

@onready var btn_move: Button = $MarginContainer/VBoxContainer/GridContainer/btnMove
@onready var btn_inspect: Button = $MarginContainer/VBoxContainer/GridContainer/btnInspect
@onready var btn_talk: Button = $MarginContainer/VBoxContainer/GridContainer/btnTalk
@onready var btn_use_item: Button = $MarginContainer/VBoxContainer/GridContainer/btnUseItem
@onready var btn_end: Button = $MarginContainer/VBoxContainer/HBoxContainer/btnEnd
@onready var btn_punch: Button = $MarginContainer/VBoxContainer/HBoxContainer/btnPunch
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var h_box_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer

func _ready() -> void:
	btn_move.disabled = true
	btn_inspect.disabled = true
	btn_talk.disabled = true
	btn_use_item.disabled = true
	btn_end.disabled = true
	enable_hunt(false)

func enable_btns():
	btn_move.disabled = false
	btn_inspect.disabled = false
	btn_talk.disabled = false
	btn_use_item.disabled = false
	btn_end.disabled = false
	btn_punch.disabled = false
	
func disable_all():
	pass
	btn_move.disabled = true
	btn_inspect.disabled = true
	btn_talk.disabled = true
	btn_use_item.disabled = true
	btn_end.disabled = true
	btn_punch.disabled = true

func enable_hunt(val: bool):
	if val:
		btn_punch.show()
		btn_end.custom_minimum_size.x = 172
	else:
		btn_punch.hide()
		btn_end.custom_minimum_size.x = 350
		
	grid_container.queue_redraw()
	grid_container.queue_sort()
	h_box_container.queue_redraw()
	h_box_container.queue_sort()

func _on_btn_move_pressed() -> void:
	btn_move_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_inspect_pressed() -> void:
	btn_inspect_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_talk_pressed() -> void:
	btn_talk_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_use_item_pressed() -> void:
	btn_use_item_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_end_pressed() -> void:
	btn_end_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_punch_pressed() -> void:
	btn_punch_signal.emit()
	AudioManager.play_sfx(GlobalContext.select_sfx,0.7)

func _on_btn_move_mouse_entered() -> void:
	if(!btn_move.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)

func _on_btn_inspect_mouse_entered() -> void:
	if(!btn_inspect.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)

func _on_btn_talk_mouse_entered() -> void:
	if(!btn_talk.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)

func _on_btn_use_item_mouse_entered() -> void:
	if(!btn_use_item.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)

func _on_btn_end_mouse_entered() -> void:
	if(!btn_end.disabled):
		AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)
