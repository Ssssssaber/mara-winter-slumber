extends CharacterBody3D

class_name Villager

@export var walk_around_area : Area3D

@onready var navigation_agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var movement_system : MovementSystem = get_node("MovementSystem")
@onready var walk_around_timer : Timer = get_node("WalkAroundTimer")
@onready var interaction_area : Area3D = get_node("InteractionArea")

@onready var _flipH : FlipHCamera = get_node("FlipH")

var walk_around_area_sphere : Node3D

func _ready() -> void:
	walk_around_area_sphere = walk_around_area.get_node("CollisionShape3D")
	walk_around_timer.timeout.connect(walk_around)
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)

func walk_around() -> void:
	var random_position := _random_point_on_circle(walk_around_area_sphere.get_shape().radius, walk_around_area.global_transform.origin); 
	navigation_agent.set_target_position(random_position)
	
func _random_point_on_circle(radius : float, center_position : Vector3 = Vector3.ZERO) -> Vector3:
	var random_andle = randf() * TAU

	var x = radius * cos(random_andle)
	var y = radius * sin(random_andle)

	return center_position + Vector3(x, 0.0, y)
		

func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	var destination = navigation_agent.get_next_path_position()
	var distance_to_destination = global_position.distance_to(destination)
	if distance_to_destination > 0.1:  # Only move if far enough
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		_flipH.SetDirection(direction)
		velocity = direction * movement_system.base_speed
	move_and_slide()

func _on_interaction_area_body_entered(body : Node3D) -> void:
	print("VILLAGER GETS SCARED")
	var direction_away = (global_position - body.global_position).normalized()
	var flee_distance = 5.0
	var new_position = global_position + direction_away * flee_distance
	_flipH.SetDirection(direction_away)
	
	movement_system.apply_speed_modifier("scared_buff", 2.0, 1.0)

	navigation_agent.set_target_position(new_position)

	walk_around_timer.start()
