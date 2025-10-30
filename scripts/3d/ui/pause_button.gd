extends Button

func _ready() -> void:
	update_button()

func _on_pressed() -> void:
	GameManager.IsGamePause = not GameManager.IsGamePause
	update_button()
	
func update_button() -> void:
	if GameManager.IsGamePause:
		GameManager.pause_world_entities.emit()
		text = "Unpause Game"
	else:
		GameManager.unpause_world_entities.emit()
		text = "Pause Game"
	