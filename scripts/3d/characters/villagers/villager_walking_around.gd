extends Node3D

class_name VilalgerWalkingAround

func _ready() -> void:
	var house = get_parent()
	_attach_to_house(house)

func _attach_to_house(house: Node3D) -> void:
	if house and house is HouseBehaviour:
		house.add_attached_entity(self)
		return
	push_error("HouseBehaviour not found on the given house node!")
