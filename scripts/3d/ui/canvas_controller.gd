extends Node

class_name CanvasController

@export_category("General")
@export var main_ui_parent : Control

@export_category("Buttons references")
@export var ghost_ignore_button : Button
@export var speed_buff_button : Button
@export var change_direction_button : Button
@export var camera_on_mara_button : Button
@export var pause_button : Button

@export_category("Camera Button")
@export var mara_reference : Node3D
@export var camera_on_mara : bool = false

@export_category("Camera Button")
@export var ghost_debuf_panel : Panel
@export var ghost_ignore_panel : Panel
@export var speed_buff_panel : Panel

# for handling signals externally
signal change_direction()
signal speed_buff_activated()
signal ghost_ignore_activated()

func hide_ui() -> void:
	print("hide")
	main_ui_parent.visible = false

func show_ui() -> void:
	print("show")
	main_ui_parent.visible = true

func _init() -> void:
	GameManager.OnGameManagerReady.connect(init)
	DialogueManager.dialogue_started.connect(hide_ui)
	DialogueManager.battle_started_without_dialogue.connect(hide_ui)
	DialogueManager.dialogue_ended.connect(show_ui)
	DialogueManager.battle_ended.connect(show_ui)

func init() -> void:
	change_direction_button.pressed.connect(_on_change_direciton_button_pressed)
	speed_buff_button.pressed.connect(_on_speed_ability_button_ability_pressed)
	ghost_ignore_button.pressed.connect(_on_ignore_ghosts_ability_button_ability_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	camera_on_mara_button.pressed.connect(_on_camera_button_pressed)
	
	_update_pause_button()
	_update_camera_button()

func _update_pause_button() -> void:
	if GameManager.IsGamePause:
		GameManager.pause_world_entities.emit()
		pause_button.text = "Продолжить"
	else:
		GameManager.unpause_world_entities.emit()
		pause_button.text = "Остановить\n время"

func _update_camera_on_mara_button() -> void:
	if GameManager.IsGamePause:
		GameManager.pause_world_entities.emit()
		pause_button.text = "Продолжить"
	else:
		GameManager.unpause_world_entities.emit()
		pause_button.text = "Остановить\nвремя"

func _update_camera_button() -> void:
	if camera_on_mara:
		GameManager.SetCameraTarget(mara_reference)
		camera_on_mara_button.text = "Свободный\nобзор"
	else:
		GameManager.SetCameraTarget(null)
		camera_on_mara_button.text = "Фокус\nна Мару"

func _on_change_direciton_button_pressed() -> void:
	change_direction.emit()

func _on_speed_ability_button_ability_pressed() -> void:
	speed_buff_activated.emit()

func _on_ignore_ghosts_ability_button_ability_pressed() -> void:
	ghost_ignore_activated.emit()

func _on_camera_button_pressed() -> void:
	camera_on_mara = not camera_on_mara
	_update_camera_button()

func _on_pause_button_pressed() -> void:
	GameManager.IsGamePause = not GameManager.IsGamePause
	_update_pause_button()
