extends Button

func _ready() -> void:
	update_button()

func _on_pressed() -> void:
	update_button()
	
func update_button() -> void:
	if GameManager.IsGamePause:
		GameManager.Pause()
		text = "Unpause Game"
	else:
		GameManager.Unpause()
		text = "Pause Game"
	