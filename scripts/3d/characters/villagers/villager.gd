extends CharacterBody3D

class_name Villager

@export var walk_around_area : Area3D
@export	var flee_distance := 5.0
@export var audio_manager : Node3D
@export var _movement : MovementSystem

@onready var navigation_agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var movement_system : MovementSystem = get_node("MovementSystem")
@onready var animated_sprite : AnimatedSprite3D = get_node("RotatableNodes/AnimatedSprite3D")
@onready var walk_around_timer : Timer = get_node("WalkAroundTimer")
@onready var interaction_area : Area3D = get_node("InteractionArea")

@onready var _flipH : FlipHCamera = get_node("FlipH")

var walk_around_area_sphere : Node3D
var is_scared = false

func _ready() -> void:
	walk_around_area_sphere = walk_around_area.get_node("CollisionShape3D")
	walk_around_timer.timeout.connect(walk_around)
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	
	GameManager.pause_world_entities.connect(pause_timer)
	GameManager.unpause_world_entities.connect(unpause_timer)

func walk_around() -> void:
	if is_scared:
		return
	var random_position := _random_point_on_circle(walk_around_area_sphere.get_shape().radius, walk_around_area.global_transform.origin); 
	navigation_agent.set_target_position(random_position)
	animated_sprite.play("moving")
	
func _random_point_on_circle(radius : float, center_position : Vector3 = Vector3.ZERO) -> Vector3:
	var random_andle = randf() * TAU

	var x = radius * cos(random_andle)
	var y = radius * sin(random_andle)

	return center_position + Vector3(x, 0.0, y)
		
func unpause_timer() -> void:
	walk_around_timer.paused = false

func pause_timer() -> void:
	walk_around_timer.paused = true

func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	if is_scared:
		return

	var destination = navigation_agent.get_next_path_position()
	var distance_to_destination = global_position.distance_to(destination)
	if distance_to_destination > 0.1:
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		_flipH.SetDirection(direction)
		velocity = direction * movement_system.base_speed
		animated_sprite.play("moving")
		if not audio_manager.walking_audio.is_playing():
			audio_manager.walking_audio.play()
	else:
		animated_sprite.play("standing")
		audio_manager.walking_audio.stop()
	move_and_slide()

func _on_modifier_added(modifier_name : String) -> void:
	audio_manager.walking_audio.pitch_scale = 2 *_movement._calculate_effective_speed() / _movement.base_speed

func _on_modifier_removed(_modifier_name : String) -> void:
	audio_manager.walking_audio.pitch_scale = 2 * _movement._calculate_effective_speed() / _movement.base_speed

func _on_interaction_area_body_entered(body : Node3D) -> void:
	is_scared = true
	audio_manager.scream_audio.play()
	animated_sprite.play("scared")  # Play the scared animation here
	audio_manager.walking_audio.stop()
	await get_tree().create_timer(1.0).timeout
	is_scared = false

	if not audio_manager.walking_audio.is_playing():
			audio_manager.walking_audio.play()
	var direction_away = (global_position - body.global_position).normalized()
	var new_position = global_position + direction_away * flee_distance
	_flipH.SetDirection(direction_away)
	
	movement_system.apply_speed_modifier("scared_buff", 2.0, 1.0)

	navigation_agent.set_target_position(new_position)
	animated_sprite.play("moving")

	walk_around_timer.start()
