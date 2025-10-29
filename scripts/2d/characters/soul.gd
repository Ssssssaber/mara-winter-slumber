extends CharacterBody2D

class_name Soul

# Настройки движения
var movement_speed: float = 15.0
var current_direction: Vector2 = Vector2(1, 0)
var is_moving: bool = true

# Для разворота
var is_facing_right: bool = true
var previous_direction: Vector2 = Vector2(1, 0)

# Улучшенное движение
var wander_timer: float = 0.0
var wander_interval: float = 3.0
var smooth_turn_speed: float = 2.0
var target_direction: Vector2 = Vector2(1, 0)

# Система испуга
var is_frightened: bool = false
var fright_timer: float = 0.0
var fright_duration: float = 1.5

# Здоровье
var max_health: int = 2
var current_health: int = max_health
var health_bar: ProgressBar

# Ссылки
@onready var soul_area: ColorRect = get_parent()
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

# Смещение HP-бара относительно души
var health_bar_offset: Vector2 = Vector2(-15, -70)

func _ready():
	add_to_group("soul")
	
	# Устанавливаем начальную позицию в центре области
	position = soul_area.size / 2

	# Убедимся что начальное направление правильное
	current_direction = Vector2(1, 0).normalized()
	target_direction = current_direction
	previous_direction = current_direction
	
	# Создаем health bar
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(50, 8)
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_child(health_bar)
	
	# Устанавливаем начальную позицию HP-бара
	_update_health_bar_position()
	
	print("Душа создана. Начальное направление: ", current_direction)
	print("Начальная позиция: ", position)

func _physics_process(delta):
	if is_moving:
		_update_movement(delta)
		_update_sprite_direction()
		_move_soul(delta)

func _update_movement(delta):
	wander_timer += delta
	
	if not is_frightened:
		if wander_timer >= wander_interval:
			_set_random_direction()
			wander_timer = 0.0
		
		# Плавно поворачиваем к целевому направлению
		current_direction = current_direction.move_toward(target_direction, smooth_turn_speed * delta)
		current_direction = current_direction.normalized()

func _move_soul(delta):
	velocity = current_direction * movement_speed
	
	var area_rect = soul_area.get_rect()
	var soul_size = Vector2(80, 80)
	var new_position = position + velocity * delta
	
	# Безопасное расстояние от границ
	var safe_margin2: float = 60
	
	# Рассчитываем границы с безопасной зоной
	var left_bound = safe_margin2
	var right_bound = area_rect.size.x - safe_margin2
	var top_bound = safe_margin2
	var bottom_bound = area_rect.size.y - safe_margin2
	
	# Проверяем и корректируем позицию для каждой границы
	var bounced = false
	
	if new_position.x < left_bound:
		current_direction.x = abs(current_direction.x)
		new_position.x = left_bound
		bounced = true
		print("Отскок от левой границы (безопасная зона)")
	elif new_position.x > right_bound:
		current_direction.x = -abs(current_direction.x)
		new_position.x = right_bound
		bounced = true
		print("Отскок от правой границы (безопасная зона)")
	
	if new_position.y < top_bound:
		current_direction.y = abs(current_direction.y)
		new_position.y = top_bound
		bounced = true
		print("Отскок от верхней границы (безопасная зона)")
	elif new_position.y > bottom_bound:
		current_direction.y = -abs(current_direction.y)
		new_position.y = bottom_bound
		bounced = true
		print("Отскок от нижней границы (безопасная зона)")
	
	# Добавляем небольшую случайность при отскоке
	if bounced:
		current_direction = current_direction.rotated(randf_range(-0.2, 0.2))
		current_direction = current_direction.normalized()
		target_direction = current_direction
	
	position = new_position
	move_and_slide()

func _set_random_direction():
	# Генерируем случайное направление
	var random_angle = randf() * 2 * PI
	target_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
	print("Случайное направление: ", target_direction)

func _update_sprite_direction():
	if not sprite:
		return
	
	# Определяем нужно ли развернуться
	var should_face_right = current_direction.x >= 0
	
	# Если направление изменилось - разворачиваем все элементы
	if should_face_right != is_facing_right:
		is_facing_right = should_face_right
		_flip_all_elements()

func _flip_all_elements():
	# Разворачиваем спрайт
	if sprite:
		sprite.scale.x = abs(sprite.scale.x) * (1 if is_facing_right else -1)
	
	# Разворачиваем CollisionPolygon2D
	if collision:
		# Для CollisionPolygon2D нужно инвертировать scale по X
		collision.scale.x = abs(collision.scale.x) * (1 if is_facing_right else -1)
	
	# Обновляем позицию HP-бара
	_update_health_bar_position()

func _update_health_bar_position():
	if not health_bar:
		return
	
	# Если смотрим вправо - HP-бар слева сверху
	if is_facing_right:
		health_bar.position = health_bar_offset
	# Если смотрим влево - зеркально смещаем HP-бар
	else:
		# Инвертируем X-координату и компенсируем ширину HP-бара
		health_bar.position = Vector2(-health_bar_offset.x - health_bar.size.x - 10, health_bar_offset.y)

func intimidate_from_point(fright_point_global: Vector2):
	print("=== ИСПУГ ОТ ТОЧКИ ===")
	print("Глобальная позиция точки испуга: ", fright_point_global)
	print("Глобальная позиция души: ", global_position)
	
	# Вектор от души к точке испуга в глобальных координатах
	var to_fright_point = fright_point_global - global_position
	print("Вектор к точке испуга (глобальный): ", to_fright_point)
	print("Длина вектора: ", to_fright_point.length())
	
	# Двигаемся в ПРОТИВОПОЛОЖНУЮ сторону
	var direction_away = -to_fright_point.normalized()
	
	print("Направление ОТ точки: ", direction_away)
	
	# Если точка очень близко к душе, выбираем случайное направление
	if to_fright_point.length() < 50:  # 50 пикселей - минимальное расстояние
		print("Точка слишком близко, выбираем случайное направление")
		var random_angle = randf() * 2 * PI
		direction_away = Vector2(cos(random_angle), sin(random_angle))
	
	# Устанавливаем новое направление
	current_direction = direction_away.normalized()
	target_direction = current_direction
	
	print("Установлено направление движения: ", current_direction)
	
	# Активируем режим испуга
	is_frightened = true
	fright_timer = 0.0
	movement_speed = 20.0
	
	# Возвращаем нормальную скорость через время
	get_tree().create_timer(fright_duration).timeout.connect(
		func(): 
			if is_moving and is_instance_valid(self):
				movement_speed = 15.0
				is_frightened = false
				print("Испуг закончился")
	, CONNECT_ONE_SHOT)

# Альтернативный вариант - испуг в противоположную сторону
func intimidate_from_point_alternative(fright_point_global: Vector2):
	print("=== АЛЬТЕРНАТИВНЫЙ ИСПУГ ===")
	
	# Вектор от души к точке испуга
	var to_fright_point = fright_point_global - global_position
	print("Вектор к точке испуга: ", to_fright_point)
	
	# Двигаемся в ПРОТИВОПОЛОЖНУЮ сторону
	var direction_away = -to_fright_point.normalized()
	
	print("Направление ОТ точки: ", direction_away)
	
	current_direction = direction_away.normalized()
	target_direction = current_direction
	
	is_frightened = true
	fright_timer = 0.0
	movement_speed = 20.0
	
	get_tree().create_timer(fright_duration).timeout.connect(
		func(): 
			if is_moving and is_instance_valid(self):
				movement_speed = 15.0
				is_frightened = false
	, CONNECT_ONE_SHOT)

# Простой испуг (старая механика)
func intimidate():
	current_direction = -current_direction
	target_direction = current_direction
	print("Простой испуг! Направление: ", current_direction)

func take_damage() -> bool:
	if current_health > 0:
		current_health -= 1
		health_bar.value = current_health
		
		print("Душа получила урон! Здоровье: ", current_health)
		
		get_tree().call_group("battle_controller", "_on_soul_damaged")
		
		if current_health <= 0:
			_on_death()
		
		return true
	return false

func _on_death():
	is_moving = false
	velocity = Vector2.ZERO
	print("Душа побеждена!")
	get_tree().call_group("battle_controller", "end_battle", true)

func get_rect() -> Rect2:
	var soul_size = Vector2(80, 80)
	return Rect2(position - soul_size / 2, soul_size)
