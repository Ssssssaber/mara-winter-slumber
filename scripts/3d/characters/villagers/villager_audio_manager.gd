extends Node3D

@export var audio_manager : AudioStreamPlayer3D
@export var scream_timer : Timer

func scream() -> void:
	if not scream_timer.is_stopped():
		return

	audio_manager.play()
	scream_timer.start()

