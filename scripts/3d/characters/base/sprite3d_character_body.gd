extends Node

class_name Sprite3DCharacterBody

@export var _animated_sprite : AnimatedSprite3D
func _init() -> void:
	pass 

func _flip_sprite() -> void:
	_animated_sprite.flip_h = not _animated_sprite.flip_h

func set_flip(value : bool) -> void:
	_animated_sprite.flip_h = value;
