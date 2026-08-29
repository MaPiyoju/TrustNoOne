extends Resource
class_name  MissionRes

@export var title: String
@export var description: String
@export var description_img: String

@export var good_ending_txt: String
@export var good_ending_img: String
@export var bad_ending_txt: String
@export var bad_ending_img: String
@export var survive_ending_txt: String
@export var survive_ending_img: String

@export var traitor_threshold: int#Number of turns in which the traitor is revealed
@export var survive_threshold: int#Number of turn to "escape"
@export var traitor_excuse: String

@export var allies_txt: Array[String]
@export var traitor_txt: Array[String]
@export var dead_txt: String
