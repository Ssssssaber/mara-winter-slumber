extends Node

@onready var pie_timer : Node3D = get_node("PieTimerWorld")
@onready var interaction_area : Area3D = get_node("Area3D")

func _ready() -> void:
	interaction_area.body_entered.connect(_on_area_3d_body_entered)
	pie_timer.timer.timeout.connect(_on_pie_timer_timeout)

func _spawn_ghost() -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("House entered by: ", body.name)
	pie_timer.visible = false

func _on_pie_timer_timeout() -> void:
	_spawn_ghost()
