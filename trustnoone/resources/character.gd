extends Resource
class_name CharacterRes

signal stat_changed(stat: PropertyType.PropertyEnum, new_value: int)
signal die

@export var name: String
@export var mini_figure: String
@export var profile_pic: String
@export var description: String
@export var age: int

@export var speed: int
@export var speed_min: int
@export var speed_max: int

@export var strength: int
@export var strength_min: int
@export var strength_max: int

@export var aura: int 
@export var aura_min: int
@export var aura_max: int

@export var knowledge: int
@export var knowledge_min: int
@export var knowledge_max: int

@export var items: Array[ItemRes]

var screams := ["res://assets/audio/damage_0.ogg", "res://assets/audio/damage_1.ogg"]

func modify_stat(stat: PropertyType.PropertyEnum, amount: int):
	match stat:
		PropertyType.PropertyEnum.AURA:
			var rnd = randi_range(0, screams.size()-1)
			AudioManager.play_sfx(load(screams[rnd]),0.7)
			aura = clampi(aura + amount, aura_min, aura_max)
			stat_changed.emit(PropertyType.PropertyEnum.AURA, aura)
			if(aura == 0):
				die.emit()
		PropertyType.PropertyEnum.KNOWLEDGE:
			knowledge = clampi(knowledge + amount, knowledge_min, knowledge_max)
			stat_changed.emit(PropertyType.PropertyEnum.KNOWLEDGE, knowledge)
		PropertyType.PropertyEnum.SPEED:
			speed = clampi(speed + amount, speed_min, speed_max)
			stat_changed.emit(PropertyType.PropertyEnum.SPEED, speed)
		PropertyType.PropertyEnum.STRENGTH:
			strength = clampi(strength + amount, strength_min, strength_max)
			stat_changed.emit(PropertyType.PropertyEnum.STRENGTH, strength)

func get_stat(stat: PropertyType.PropertyEnum) -> int:
	match stat:
		PropertyType.PropertyEnum.AURA: return aura
		PropertyType.PropertyEnum.KNOWLEDGE: return knowledge
		PropertyType.PropertyEnum.SPEED: return speed
		PropertyType.PropertyEnum.STRENGTH: return strength
		_: return 0

func isDead() -> bool:
	return aura == 0
