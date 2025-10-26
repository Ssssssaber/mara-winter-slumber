extends Node

@onready var pie_timer : Node3D = get_node("PieTimerWorld") 

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("House entered by: ", body.name)
	pie_timer.visible = false
