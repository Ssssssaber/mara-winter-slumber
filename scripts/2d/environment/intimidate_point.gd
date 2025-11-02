extends Sprite2D

class_name IntimidatePoint

var is_preview: bool = true
var soul_area: ColorRect
var is_position_valid: bool = true

func _ready():
	modulate = Color.PURPLE
	scale = Vector2(0.5, 0.5)

func set_soul_area(area: ColorRect):
	soul_area = area

func _process(delta):
	if is_preview:
		_update_preview_position()

func _update_preview_position():
	if not soul_area:
		# Если SoulArea не установлен, используем позицию без ограничений
		var mouse_pos = get_global_mouse_position()
		var local_mouse_pos = get_parent().get_global_transform().affine_inverse() * mouse_pos
		position = local_mouse_pos
		return
	
	var mouse_pos = get_global_mouse_position()
	var area_global_rect = Rect2(soul_area.global_position, soul_area.size)
	
	# Проверяем валидность позиции
	is_position_valid = area_global_rect.has_point(mouse_pos)
	
	# Обновляем визуал в зависимости от валидности позиции
	if is_position_valid:
		modulate = Color.PURPLE
		# Позиция валидна - устанавливаем как есть
		var local_mouse_pos = get_parent().get_global_transform().affine_inverse() * mouse_pos
		position = local_mouse_pos
	else:
		modulate = Color.RED
		# Позиция невалидна - не обновляем позицию (точка остается на последней валидной позиции)
		# Или можно ограничить позицию границами:
		# var clamped_pos = _clamp_to_soul_area(mouse_pos)
		# var local_clamped_pos = get_parent().get_global_transform().affine_inverse() * clamped_pos
		# position = local_clamped_pos

func _clamp_to_soul_area(global_pos: Vector2) -> Vector2:
	var area_global_rect = Rect2(soul_area.global_position, soul_area.size)
	return Vector2(
		clamp(global_pos.x, area_global_rect.position.x, area_global_rect.end.x),
		clamp(global_pos.y, area_global_rect.position.y, area_global_rect.end.y)
	)

# Функция для проверки валидности позиции (используется в BattleController)
func is_valid_position() -> bool:
	return is_position_valid

func activate():
	is_preview = false
	set_process(false)