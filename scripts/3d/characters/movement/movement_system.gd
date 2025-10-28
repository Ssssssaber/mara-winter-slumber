extends Node3D

class_name MovementSystem

@export var base_speed: float = 5.0
@export var acceleration: float = 20.0 # How quickly to reach target speed
@export var friction: float = 15.0 # How quickly to stop

@onready var body: CharacterBody3D = get_parent() as CharacterBody3D

var current_direction: Vector3 = Vector3.ZERO
var effective_speed: float = base_speed

# Speed modifiers: Array of dictionaries { "multiplier": float, "duration": float }
var speed_modifiers: Dictionary = {}

var _ignore_negative_modifiers : bool = false

signal movement_started(direction: Vector3)
signal movement_stopped

func _ready() -> void:
	if body == null:
		push_error("Parent is not a CharacterBody3D! Check your node hierarchy.")
		set_process(false)  # Disable script if invalid

func set_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()

"""
Applies a speed modifier (buff or debuff) to the character's movement.

Modifiers stack multiplicatively and can be temporary or permanent.
For example, a 1.5 multiplier increases speed by 50%, while 0.8 decreases it by 20%.

@param multiplier: The speed multiplier (e.g., 1.5 for +50%, 0.8 for -20%).
@param duration: Duration in seconds (-1 for permanent).
"""
func apply_speed_modifier(modifier_name : String, multiplier: float, duration: float) -> void:
	if _ignore_negative_modifiers:
		if modifier_name == Constants.GHOST_MOVEMENT_MODIFIER:
			return
	
	if modifier_name == Constants.MARA_IGNORE_GHOSTS:
		_ignore_negative_modifiers = true

	speed_modifiers[modifier_name] = {
		"multiplier": multiplier,
		"duration": duration
	}

func remove_modifier(modifier_name : String) -> bool:

	if modifier_name == Constants.MARA_IGNORE_GHOSTS:
		_ignore_negative_modifiers = false

	return speed_modifiers.erase(modifier_name)

func _calculate_effective_speed() -> float:
	var total_multiplier = 1.0
	for modifier_name in speed_modifiers:
		total_multiplier *= speed_modifiers[modifier_name]["multiplier"]
	return base_speed * total_multiplier

func _physics_process(delta: float) -> void:
	for modifier_name in speed_modifiers:  # Iterate backwards to safely remove
		if speed_modifiers[modifier_name]["duration"] > 0:
			speed_modifiers[modifier_name]["duration"] -= delta
		if speed_modifiers[modifier_name]["duration"] <= 0 and speed_modifiers[modifier_name]["duration"] != -1:
			remove_modifier(modifier_name)

	effective_speed = _calculate_effective_speed()
	
	if current_direction != Vector3.ZERO:
		var target_velocity = current_direction * effective_speed
		body.velocity.x = move_toward(body.velocity.x, target_velocity.x, acceleration * delta)
		body.velocity.z = move_toward(body.velocity.z, target_velocity.z, acceleration * delta)
		if body.velocity.length() > 0.1:  # Threshold to avoid spam
			emit_signal("movement_started", current_direction)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, friction * delta)
		body.velocity.z = move_toward(body.velocity.z, 0, friction * delta)
		if body.velocity.length() < 0.1:
			emit_signal("movement_stopped")
	
	body.move_and_slide()
