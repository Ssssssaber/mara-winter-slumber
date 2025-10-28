extends Node

class_name CanvasController

signal change_direction()
signal speed_buff_activated()
signal ghost_ignore_activated()

func _on_ignore_ghosts_button_pressed() -> void:
	ghost_ignore_activated.emit()

func _on_speed_buff_button_pressed() -> void:
	speed_buff_activated.emit()

func _on_change_direciton_button_pressed() -> void:
	change_direction.emit()