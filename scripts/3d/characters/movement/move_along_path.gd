extends Node3D

@export var movement_system_path: NodePath = NodePath("MovementSystem")
@export var loop_path: bool = true

@onready var path: Path3D = GameManager.GetMainPath()
@onready var movement_system: Node = get_parent().get_node("MovementSystem")
var curve: Curve3D

var path_progress: float = 0.0  # Distance along the path

func _ready():
	curve = path.curve
	if curve == null:
		push_error("Path3D has no Curve3D assigned!")
		set_process(false)

func _physics_process(delta):
	if curve == null:
		return

	var path_length = curve.get_baked_length()
	if path_length == 0:
		return

	# Get current position on the path
	var current_pos = curve.sample_baked(path_progress)
	global_transform.origin = current_pos

	# Calculate next progress point a bit ahead for direction
	var look_ahead_distance = 1.0  # Adjust for smoothness
	var next_progress = path_progress + look_ahead_distance
	if next_progress > path_length:
		if loop_path:
			next_progress = fmod(next_progress, path_length)
		else:
			next_progress = path_length

	var next_pos = curve.sample_baked(next_progress)

	# Calculate direction vector toward next_pos (ignore Y if you want flat movement)
	var direction = (next_pos - current_pos).normalized()

	# Send direction to MovementSystem
	movement_system.set_direction(direction)

	# Advance progress based on MovementSystem speed and delta
	# Use effective speed from MovementSystem if you want exact sync (optional)
	var speed = movement_system.base_speed
	# If you want to consider modifiers, you can add a getter to MovementSystem for effective speed

	path_progress += speed * delta
	if path_progress > path_length:
		if loop_path:
			path_progress = fmod(next_progress, path_length)
		else:
			path_progress = path_length
			# Stop movement at end
			movement_system.set_direction(Vector3.ZERO)
