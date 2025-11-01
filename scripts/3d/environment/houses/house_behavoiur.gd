extends Node3D

class_name HouseBehaviour

@onready var pie_timer : Node3D = get_node("PieTimerWorld")
@onready var interaction_area : Area3D = get_node("Area3D")

@onready var ok_mesh : Node3D = get_node_or_null("HouseStates/Ok")
@onready var abandoned_mesh : Node3D = get_node_or_null("HouseStates/Abandoned")

var attached_entities : Array[Node3D] = []

@export var is_abandoned : bool = false:
	set(new_value):
		is_abandoned = new_value
		_update_abandoned_state(is_abandoned)
	get:
		return is_abandoned

func _update_abandoned_state(abandoned : bool) -> void:
	if (not ok_mesh) or (not abandoned_mesh):
		return

	ok_mesh.visible = !abandoned
	abandoned_mesh.visible = abandoned
	if abandoned:
		free_attached_entities()
		_spawn_ghost_near_self()

func _ready() -> void:
	interaction_area.body_entered.connect(_on_area_3d_body_entered)
	pie_timer.timer.timeout.connect(_on_pie_timer_timeout)
	# _spawn_ghost_near_self()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("House entered by: ", body.name)
	pie_timer.stop_timer()

func _spawn_ghost_near_self() -> void:
	var ghost = GameManager.SpawnGhost()
	var near_house_progress = GameManager.GetMainPathProgress(self)
	GameManager.AddEntityToPath(ghost, near_house_progress, randi() % 2 == 0)

func _on_pie_timer_timeout() -> void:
	is_abandoned = true

func add_attached_entity(entity: Node3D) -> void:
	attached_entities.append(entity)

func free_attached_entities() -> void:
	for entity in attached_entities:
		if is_instance_valid(entity):
			entity.queue_free()
	attached_entities.clear()