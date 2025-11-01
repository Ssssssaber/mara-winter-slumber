extends Node

func _ready() -> void:
	GameManager.call_deferred("Initialize")