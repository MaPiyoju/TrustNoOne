extends Control

var steps: Array[Control]

@onready var step_0: Control = $CanvasLayer/Step_0
@onready var step_1: Control = $CanvasLayer/Step_1
@onready var step_2: Control = $CanvasLayer/Step_2
@onready var step_3: Control = $CanvasLayer/Step_3
@onready var step_4: Control = $CanvasLayer/Step_4
@onready var step_5: Control = $CanvasLayer/Step_5
@onready var step_6: Control = $CanvasLayer/Step_6
@onready var step_7: Control = $CanvasLayer/Step_7
@onready var next_btn: Button = $CanvasLayer/NextBtn
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var currentStep := 0

func _ready() -> void:
	steps = [
		step_0,
		step_1,
		step_2,
		step_3,
		step_4,
		step_5,
		step_6,
		step_7
	]
	if(GlobalContext.tutorial_check):
		canvas_layer.visible = false
	
func _on_next_btn_mouse_entered() -> void:
	AudioManager.play_sfx(GlobalContext.hover_sfx,0.2)

func _on_next_btn_pressed() -> void:
	if(currentStep<steps.size()-1):
		currentStep+=1
		for i in range(steps.size()):
			steps[i].visible = false
			if(currentStep == i):
				steps[i].visible = true
	else:
		GlobalContext.tutorial_check = true
		next_btn.text = "Play"
		canvas_layer.visible = false
		
	AudioManager.play_sfx(GlobalContext.select_sfx,0.2)
	
	
