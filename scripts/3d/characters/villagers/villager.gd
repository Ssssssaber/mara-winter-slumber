extends CharacterBody3D

@export var walk_around_area : Area3D

@onready var navigation_agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var movement_system : MovementSystem = get_node("MovementSystem")

var area_sphere : Node3D

func _ready() -> void:
	area_sphere = walk_around_area.get_node("CollisionShape3D")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position := _random_point_on_circle(area_sphere.get_shape().radius, walk_around_area.global_transform.origin); 
		navigation_agent.set_target_position(random_position)

func _random_point_on_circle(radius : float, center_position : Vector3 = Vector3.ZERO) -> Vector3:
	var random_andle = randf() * TAU

	var x = radius * cos(random_andle)
	var y = radius * sin(random_andle)

	return center_position + Vector3(x, 0.0, y)
		

func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	var destination = navigation_agent.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	velocity = direction * movement_system.base_speed
	move_and_slide()
