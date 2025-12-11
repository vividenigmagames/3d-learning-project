extends Node3D

@onready var player = $player3d
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
		
func _physics_process(delta: float) -> void:
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)
