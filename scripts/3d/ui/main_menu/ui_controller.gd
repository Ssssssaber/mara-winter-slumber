extends Node

@export var main_menu_layout : VBoxContainer 
@export var options_layout : VBoxContainer

func _on_start_game_button_pressed() -> void:
	GameManager.StartGame(get_parent())

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	main_menu_layout.visible = false
	options_layout.visible = true

func _on_options_main_menu_button_pressed() -> void:
	main_menu_layout.visible = true
	options_layout.visible = false

func _on_snow_check_box_toggled(toggled_on: bool) -> void:
	if GameManager.Initialized:
		GameManager.snow_particles.emitting = toggled_on
	else:
		GameManager.particles_enabled = toggled_on

func _on_fog_check_box_toggled(toggled_on: bool) -> void:
	GameManager.world_environment.environment.fog_enabled = toggled_on

func _on_bloom_check_box_toggled(toggled_on: bool) -> void:
	GameManager.world_environment.environment.glow_enabled = toggled_on
