extends Node

@onready var music_player: AudioStreamPlayer = $music_player
@onready var sfx_player: AudioStreamPlayer = $sfx_player

var play_rnd:= false
var rnd_tracks: Array[String]
var rnd_play_margin: float
var last_play: float = 0.0

var music_tween: Tween
var rnd_track: AudioStream

func play_music(stream: AudioStream, loop := true):
	music_player.stop()
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	
	music_player.stream = stream
	music_player.play()
	set_music_volume(0.2)

func stop_music(fade_duration: float = 0) -> void:
	if not music_player.playing:
		return
		
	if(fade_duration == 0):
		music_player.stop()
		return	
	
	if music_tween and music_tween.is_valid():
		music_tween.kill()

	music_tween = create_tween()

	music_tween.tween_property(
		music_player,
		"volume_db",
		-80.0,
		fade_duration
	)

	music_tween.tween_callback(music_player.stop)
	music_tween.tween_callback(_reset_music_volume)

func set_music_volume(vol: float):
	music_player.volume_linear = vol

func play_sfx(stream: AudioStream, vol: float = 0.0):
	sfx_player.stop()
	set_sfx_volume(vol)
	sfx_player.stream = stream
	sfx_player.play()

func set_sfx_volume(vol: float):
	sfx_player.volume_linear = vol

func _process(delta: float) -> void:
	if(play_rnd):
		var currentTime = Time.get_ticks_msec() / 1000.0
		if(currentTime - last_play > rnd_play_margin):
			last_play = currentTime
			var rnd = randf_range(0, 1)
			if(rnd > 0.7):
				var rnd_track = randi_range(0, rnd_tracks.size()-1)
				play_music(load(rnd_tracks[rnd_track]), false)

func set_play_rnd(tracks: Array[String],play_margin: float):
	play_rnd = true
	rnd_tracks = tracks
	rnd_play_margin = play_margin

func _reset_music_volume() -> void:
	music_player.volume_db = 0.0
