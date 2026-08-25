extends CanvasLayer
class_name GameInfoController

@onready var actions: Label = $MarginContainer/HBoxContainer/actions
@onready var turns: Label = $MarginContainer/HBoxContainer/turns

func update_actions(maxVal:int, current:int):
	actions.text = "ACTIONS: " + str(current) + " / " + str(maxVal)
	
func update_turns():
	GlobalContext.current_turn-=1
	turns.text = "TURNS: " + str(GlobalContext.current_turn) + " / " + str(GlobalContext.max_turns)
