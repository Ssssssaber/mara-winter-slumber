extends Node3D

@export var base_speed: float = 5.0
@export var acceleration: float = 20.0 # How quickly to reach target speed
@export var friction: float = 15.0 # How quickly to stop

@onready var body: CharacterBody3D = get_parent().get_node("Body")

var current_direction: Vector3 = Vector3.ZERO

# Speed modifiers: Array of dictionaries { "multiplier": float, "duration": float }
var speed_modifiers: Array = []

signal movement_started(direction: Vector3)
signal movement_stopped

# Public method to set movement direction
func set_direction(direction: Vector3) -> void:
	current_direction = direction.normalized()

"""
Applies a speed modifier (buff or debuff) to the character's movement.

Modifiers stack multiplicatively and can be temporary or permanent.
For example, a 1.5 multiplier increases speed by 50%, while 0.8 decreases it by 20%.

@param multiplier: The speed multiplier (e.g., 1.5 for +50%, 0.8 for -20%).
@param duration: Duration in seconds (-1 for permanent).
"""
func apply_speed_modifier(multiplier: float, duration: float) -> void:
	speed_modifiers.append({
		"multiplier": multiplier,
		"duration": duration
	})

# Internal
func _get_effective_speed() -> float:
	var total_multiplier = 1.0
	for modifier in speed_modifiers:
		total_multiplier *= modifier["multiplier"]
	return base_speed * total_multiplier

func _physics_process(delta: float) -> void:
	# Update speed modifiers (decrease duration, remove expired)
	for i in range(speed_modifiers.size() - 1, -1, -1):  # Iterate backwards to safely remove
		if speed_modifiers[i]["duration"] > 0:
			speed_modifiers[i]["duration"] -= delta
		if speed_modifiers[i]["duration"] <= 0 and speed_modifiers[i]["duration"] != -1:
			speed_modifiers.remove_at(i)
	
	var effective_speed = _get_effective_speed()
	
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
