extends Node

@export var parent_control_node : Control
@export var main_menu_layout : VBoxContainer 
@export var options_layout : VBoxContainer

@export var fog_toggle : CheckBox
@export var bloom_toggle : CheckBox
@export var snow_toggle : CheckBox

func set_initial_paramenters() -> void:
	fog_toggle.button_pressed = GameManager.world_environment.environment.fog_enabled
	bloom_toggle.button_pressed = GameManager.world_environment.environment.glow_enabled
	if GameManager.Initialized:
		snow_toggle.button_pressed = GameManager.snow_particles.emitting
	else:
		snow_toggle.button_pressed = GameManager.particles_enabled

func set_menu_visible(value : bool) -> void:
	set_initial_paramenters()
	if not value and options_layout.visible:
		_on_options_main_menu_button_pressed()
	parent_control_node.visible = value

func _on_start_game_button_pressed() -> void:
	GameManager.PlayButtonSound()
	if not GameManager.Initialized:
		GameManager.StartGame(get_parent())
	else:
		GameManager.SetShowGamePauseMenu(false)
		GameManager.Unpause()

func _on_quit_game_button_pressed() -> void:
	GameManager.PlayButtonSound()
	get_tree().quit()

func _on_options_button_pressed() -> void:
	GameManager.PlayButtonSound()
	main_menu_layout.visible = false
	options_layout.visible = true

func _on_options_main_menu_button_pressed() -> void:
	GameManager.PlayButtonSound()
	main_menu_layout.visible = true
	options_layout.visible = false

func _on_snow_check_box_toggled(toggled_on: bool) -> void:
	GameManager.PlayButtonSound()
	if GameManager.Initialized:
		GameManager.snow_particles.emitting = toggled_on
	else:
		GameManager.particles_enabled = toggled_on

func _on_fog_check_box_toggled(toggled_on: bool) -> void:
	GameManager.PlayButtonSound()
	GameManager.world_environment.environment.fog_enabled = toggled_on

func _on_bloom_check_box_toggled(toggled_on: bool) -> void:
	GameManager.PlayButtonSound()
	GameManager.world_environment.environment.glow_enabled = toggled_on
