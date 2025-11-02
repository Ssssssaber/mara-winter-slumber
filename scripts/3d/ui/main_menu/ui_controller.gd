extends Node

func _on_start_game_button_pressed() -> void:
	GameManager.StartGame(get_parent())

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
