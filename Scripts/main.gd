extends Node3D

@onready var musicAudioStreamBG = $AudioStreamPlayerBGMusic
var backgroundMusicOn = true

func _process(delta: float) -> void:
	update_music_status()
	
func update_music_status():
	if backgroundMusicOn:
		if !musicAudioStreamBG.playing:
			musicAudioStreamBG.play()
	else:
		musicAudioStreamBG.stop()
