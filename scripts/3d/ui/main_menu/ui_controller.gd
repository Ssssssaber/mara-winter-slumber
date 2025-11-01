extends Node

func _on_start_game_button_pressed() -> void:
	GameManager.StartGame(get_parent())
