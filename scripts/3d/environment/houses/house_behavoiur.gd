extends Node3D

@onready var pie_timer : Node3D = get_node("PieTimerWorld")
@onready var interaction_area : Area3D = get_node("Area3D")

func _ready() -> void:
	interaction_area.body_entered.connect(_on_area_3d_body_entered)
	pie_timer.timer.timeout.connect(_on_pie_timer_timeout)
	# _spawn_ghost_near_self()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("House entered by: ", body.name)
	pie_timer.visible = false

func _spawn_ghost_near_self() -> void:
	var ghost = GameManager.SpawnGhost()
	var near_house_progress = GameManager.GetMainPathProgress(self)
	GameManager.AddEntityToPath(ghost, near_house_progress, randi() % 2 == 0)

func _on_pie_timer_timeout() -> void:
	_spawn_ghost_near_self()

