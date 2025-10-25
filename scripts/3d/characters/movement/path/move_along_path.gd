extends Node3D

class_name MoveAlongPath

@export var loop_path: bool = true
@export var inverted_direction: bool = false  # If true, move towards the start of the path (reverse direction)

@onready var path: Path3D = GameManager.GetMainPath()
@onready var movement_system: MovementSystem = get_parent() as MovementSystem

var curve: Curve3D

@export var path_progress: float = 0.0  # Distance along the path (will be set dynamically on spawn)

func _ready():
	curve = path.curve
	if curve == null:
		push_error("Path3D has no Curve3D assigned!")
		set_process(false)
		return
	
	# Calculate initial path_progress based on the closest point on the path to the current position
	path_progress = curve.get_closest_offset(global_transform.origin)
	
	# Debug: Print initial path_progress to verify
	print(name, "Initial path_progress: ", path_progress)
	
	# Snap the node's position to the path at the calculated progress (so it starts exactly on the path)
	global_transform.origin = curve.sample_baked(path_progress)
	

func _physics_process(delta):
	if curve == null:
		return

	var path_length = curve.get_baked_length()
	if path_length == 0:
		return

	# Get current position on the path (should match global_transform.origin after snapping)
	var current_pos = curve.sample_baked(path_progress)

	# Determine look-ahead direction based on inverted_direction
	var look_ahead_distance = 1.0
	var next_progress: float
	if inverted_direction:
		# Moving backward: look behind
		next_progress = path_progress - look_ahead_distance
		if next_progress < 0:
			if loop_path:
				next_progress = path_length + next_progress  # Wrap around to the end
			else:
				next_progress = 0  # Clamp to start
	else:
		# Moving forward: look ahead
		next_progress = path_progress + look_ahead_distance
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

	# Update path_progress based on direction
	var speed = movement_system.base_speed
	if inverted_direction:
		path_progress -= speed * delta
		if path_progress < 0:
			if loop_path:
				path_progress = path_length + path_progress  # Wrap to end
			else:
				path_progress = 0
				movement_system.set_direction(Vector3.ZERO)  # Stop at start
	else:
		path_progress += speed * delta
		if path_progress > path_length:
			if loop_path:
				path_progress = fmod(path_progress, path_length)
			else:
				path_progress = path_length
				movement_system.set_direction(Vector3.ZERO)  # Stop at end

	# Force the node to stay on the path by snapping its position each frame (overrides MovementSystem's position changes)
	global_transform.origin = curve.sample_baked(path_progress)
