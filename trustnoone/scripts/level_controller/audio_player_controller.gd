extends AudioStreamPlayer

@export var tracks: Array[String]
@export var play_margin: float
var last_play: float = 0.0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var currentTime = Time.get_ticks_msec() / 1000.0
	if(currentTime - last_play > play_margin):
		last_play = currentTime
		var rnd = randf_range(0, 1)
		if(rnd > 0.7):
			play_track()
	
func play_track():
	var rnd = randi_range(0, tracks.size()-1)
	stream = load(tracks[rnd])
	play()
