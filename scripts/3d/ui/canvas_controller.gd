extends Node

class_name CanvasController

@export var ghost_ignore_button : Button
@export var speed_buff_button : Button
@export var change_direction_button : Button

signal change_direction()
signal speed_buff_activated()
signal ghost_ignore_activated()

func _ready() -> void:
	change_direction_button.pressed.connect(_on_change_direciton_button_pressed)
	speed_buff_button.pressed.connect(_on_speed_ability_button_ability_pressed)
	ghost_ignore_button.pressed.connect(_on_ignore_ghosts_ability_button_ability_pressed)

func _on_change_direciton_button_pressed() -> void:
	change_direction.emit()

func _on_speed_ability_button_ability_pressed() -> void:
	speed_buff_activated.emit()

func _on_ignore_ghosts_ability_button_ability_pressed() -> void:
	ghost_ignore_activated.emit()
