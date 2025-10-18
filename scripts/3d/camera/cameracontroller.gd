extends Camera3D

@export var movement_speed: float = 20.0 
@export var rotation_speed: float = 0.005
@export var zoom_speed: float = 5.0 
@export var border_threshold: float = 50.0

var direction: Vector3 = Vector3.ZERO
var rotating: bool = false  # Flag for when middle mouse is held

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
    direction.x = Input.get_axis("ui_left", "ui_right")
    direction.z = Input.get_axis("ui_up", "ui_down")
    
    var mouse_pos = get_viewport().get_mouse_position()
    var viewport_rect = get_viewport().get_visible_rect()

	# Check if mouse is inside the viewport
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
        rotate_y(-event.relative.x * rotation_speed)
        rotation.x = clamp(rotation.x, -PI/2, PI/2)
