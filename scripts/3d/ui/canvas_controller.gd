extends Node

class_name CanvasController

@export var ghost_ignore_button : Button
@export var speed_buff_button : Button

signal change_direction()
signal speed_buff_activated()
signal ghost_ignore_activated()

func _on_change_direciton_button_pressed() -> void:
	change_direction.emit()

func _on_speed_ability_button_ability_pressed() -> void:
	speed_buff_activated.emit()

func _on_ignore_ghosts_ability_button_ability_pressed() -> void:
	ghost_ignore_activated.emit()
