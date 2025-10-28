extends Camera3D

class_name CameraController

@export var movement_speed: float = 20.0 
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 5.0 
@export var border_threshold: float = 50.0

@export var post_offset: Vector3 = Vector3(0.0, 10.0, 0.0)
@export var target: Node3D  # The target node to follow (set to null for free movement)
@export var follow_offset: Vector3 = Vector3(0, 5, 10)  # This now defines the *magnitude* of the post_offset (length of this vector). The direction will be dynamic.
@export var follow_smoothness: float = 5.0  # Speed of lerping towards the target position (higher = faster)
@export var zoom_factor: float = 1.0  # Multiplier for the post_offset magnitude (adjusted by zoom in following mode)

var direction: Vector3 = Vector3.ZERO
var rotating: bool = false  # Flag for when middle mouse is held
var rolling: bool = false

func set_target(node : Node3D) -> void:
	target = node

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	if target != null:
		# Following mode: Always look at the target
		look_at(target.global_transform.origin)
		
		# Calculate the magnitude from the exported follow_offset vector (its length)
		var magnitude = follow_offset.length()
		
		# Dynamic post_offset: Direction from world origin (Vector3.ZERO) to the target's position, normalized
		var offset_direction = (target.global_transform.origin - Vector3.ZERO).normalized()
		
		# If the target is exactly at the origin, offset_direction will be Vector3.ZERO (no post_offset)
		# Otherwise, scale by magnitude and zoom_factor for the full post_offset vector
		var offset_vector = offset_direction * magnitude * zoom_factor
		
		# Desired position: Target's position + dynamic post_offset (in world space, away from origin)
		var desired_pos = target.global_transform.origin + offset_vector + post_offset
		
		# Smoothly interpolate towards the desired position
		global_transform.origin = global_transform.origin.lerp(desired_pos, follow_smoothness * delta)
		
		return
	
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.z = Input.get_axis("ui_up", "ui_down")
	
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport().get_visible_rect()

	if viewport_rect.has_point(mouse_pos): 
		if mouse_pos.x < border_threshold:
			direction.x -= 1
		if mouse_pos.x > viewport_rect.size.x - border_threshold:
			direction.x += 1
		if mouse_pos.y < border_threshold:
			direction.z -= 1 
		if mouse_pos.y > viewport_rect.size.y - border_threshold:
			direction.z += 1
	
	if direction.length() > 0:
		var local_dir = direction.normalized()
		var global_dir = global_transform.basis * local_dir
		global_dir.y = 0
		if global_dir.length() > 0:
			global_dir = global_dir.normalized() 
			position += global_dir * movement_speed * delta
	
	direction = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if target != null:
		# In following mode, allow zoom (adjust zoom_factor to scale the post_offset magnitude) but disable other controls
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				zoom_factor = max(zoom_factor - 0.1, 0.1) # Prevent too small zoom (adjust step as needed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				zoom_factor += 0.1
			return # Skip other inputs (no panning, orbiting, or WASD in following mode)

	# Free movement mode inputs
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				rotating = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				rotating = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			position.y -= zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			position.y += zoom_speed

	elif event is InputEventMouseMotion and rotating:
		rotate_y(deg_to_rad(-event.relative.x * 0.1))  # Multiplied by 0.1 for sensitivity (adjust as needed)
		var pitch_change = deg_to_rad(-event.relative.y * 0.1)
		rotation.x = clamp(rotation.x + pitch_change, deg_to_rad(-90), deg_to_rad(90))  # Clamp to prevent flipping
