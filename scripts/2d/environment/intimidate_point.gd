extends Sprite2D

class_name intimidate_point

var is_preview: bool = true

func _ready():
	# Настраиваем внешний вид точки
	modulate = Color.PURPLE
	scale = Vector2(0.5, 0.5)

func _process(delta):
	if is_preview:
		# ТОЧНО ТАК ЖЕ КАК В CAPTURE_ZONE.GD
		var mouse_pos = get_global_mouse_position()
		var local_mouse_pos = get_parent().get_global_transform().affine_inverse() * mouse_pos
		position = local_mouse_pos

func activate():
	is_preview = false
	set_process(false)