extends Resource
class_name CharacterRes

signal stat_changed(stat: PropertyType.PropertyEnum, new_value: int)

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


func modify_stat(stat: PropertyType.PropertyEnum, amount: int) -> int:
	match stat:
		PropertyType.PropertyEnum.AURA:
			aura = clampi(aura + amount, aura_min, aura_max)
			return aura
		PropertyType.PropertyEnum.KNOWLEDGE:
			knowledge = clampi(knowledge + amount, knowledge_min, knowledge_max)
			return knowledge
		PropertyType.PropertyEnum.SPEED:
			speed = clampi(speed + amount, speed_min, speed_max)
			return speed
		PropertyType.PropertyEnum.STRENGTH:
			strength = clampi(strength + amount, strength_min, strength_max)
			return strength
		_:
			return 0

func get_stat(stat: PropertyType.PropertyEnum) -> int:
	match stat:
		PropertyType.PropertyEnum.AURA: return aura
		PropertyType.PropertyEnum.KNOWLEDGE: return knowledge
		PropertyType.PropertyEnum.SPEED: return speed
		PropertyType.PropertyEnum.STRENGTH: return strength
		_: return 0
