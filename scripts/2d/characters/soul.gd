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
var fright_direction: Vector2 = Vector2.ZERO  # Направление испуга

var active_capture_zones: Array = []  # Массив активных зон захвата
var avoidance_strength: float = 2.0   # Сила избегания зон
var detection_radius: float = 300.0   # Радиус обнаружения зон

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
		_update_zone_avoidance()
		_move_soul(delta)

func _update_zone_avoidance():
	# Если активен испуг - НЕ ИЗБЕГАЕМ ЗОНЫ
	if is_frightened:
		return
	
	var avoidance_direction = Vector2.ZERO
	var zone_count = 0
	
	for zone in active_capture_zones:
		if is_instance_valid(zone):
			var zone_global_pos = zone.global_position
			var distance_to_zone = global_position.distance_to(zone_global_pos)
			
			if distance_to_zone < detection_radius:
				var direction_from_zone = (global_position - zone_global_pos).normalized()
				var strength = 1.0 - (distance_to_zone / detection_radius)
				avoidance_direction += direction_from_zone * strength
				zone_count += 1
	
	if zone_count > 0:
		avoidance_direction = avoidance_direction.normalized()
		var new_direction = (current_direction + avoidance_direction * avoidance_strength).normalized()
		current_direction = new_direction
		target_direction = current_direction

func add_capture_zone(zone: Area2D):
	if not active_capture_zones.has(zone):
		active_capture_zones.append(zone)
		print("Добавлена зона захвата для избегания. Всего зон: ", active_capture_zones.size())

# Функция для удаления зоны из списка активных
func remove_capture_zone(zone: Area2D):
	if active_capture_zones.has(zone):
		active_capture_zones.erase(zone)
		print("Удалена зона захвата. Осталось зон: ", active_capture_zones.size())

func _update_movement(delta):
	wander_timer += delta
	
	# ОБНОВЛЕННАЯ ЛОГИКА С ПРИОРИТЕТАМИ
	if is_frightened:
		# ВЫСШИЙ ПРИОРИТЕТ: Испуг - используем заданное направление испуга
		current_direction = fright_direction
		target_direction = current_direction
		fright_timer += delta
		
		# Завершаем испуг по таймеру
		if fright_timer >= fright_duration:
			is_frightened = false
			print("Испуг закончился, возвращаемся к нормальному поведению")
			
	elif not active_capture_zones.is_empty():
		# СРЕДНИЙ ПРИОРИТЕТ: Избегание зон
		_update_zone_avoidance()
		
	else:
		# НИЗШИЙ ПРИОРИТЕТ: Случайное блуждание
		if wander_timer >= wander_interval:
			_set_random_direction()
			wander_timer = 0.0
		
		current_direction = current_direction.move_toward(target_direction, smooth_turn_speed * delta)
		current_direction = current_direction.normalized()


func _move_soul(delta):
	# Разная скорость в зависимости от состояния
	var current_speed = movement_speed
	if is_frightened:
		current_speed = 20.0  # Ускорение при испуге
	
	velocity = current_direction * current_speed
	
	var area_rect = soul_area.get_rect()
	var soul_size = Vector2(80, 80)
	var new_position = position + velocity * delta
	
	# Безопасное расстояние от границ
	var safe_margin2: float = 70
	
	# Рассчитываем границы с безопасной зоной
	var left_bound = safe_margin2
	var right_bound = area_rect.size.x - safe_margin2
	var top_bound = safe_margin2
	var bottom_bound = area_rect.size.y - safe_margin2
	
	# Проверяем и корректируем позицию для каждой границы
	var bounced = false
	
	if new_position.x < left_bound:
		current_direction.x = abs(current_direction.x)
		if is_frightened:
			fright_direction.x = abs(fright_direction.x)  # Также обновляем направление испуга
		new_position.x = left_bound
		bounced = true
	elif new_position.x > right_bound:
		current_direction.x = -abs(current_direction.x)
		if is_frightened:
			fright_direction.x = -abs(fright_direction.x)
		new_position.x = right_bound
		bounced = true
	
	if new_position.y < top_bound:
		current_direction.y = abs(current_direction.y)
		if is_frightened:
			fright_direction.y = abs(fright_direction.y)
		new_position.y = top_bound
		bounced = true
	elif new_position.y > bottom_bound:
		current_direction.y = -abs(current_direction.y)
		if is_frightened:
			fright_direction.y = -abs(fright_direction.y)
		new_position.y = bottom_bound
		bounced = true
	
	# Добавляем небольшую случайность при отскоке (кроме режима испуга)
	if bounced and not is_frightened:
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
		if not is_facing_right:
			collision.position = Vector2(-19,0) # Костыль
		else:
			collision.position = Vector2(0,0) # Костыль два
		
		print(collision.scale.x)
	
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
	print("=== ИСПУГ ОТ ТОЧКИ (ВЫСШИЙ ПРИОРИТЕТ) ===")
	
	# Вектор от души к точке испуга
	var to_fright_point = fright_point_global - global_position
	
	# Двигаемся в ПРОТИВОПОЛОЖНУЮ сторону
	var direction_away = -to_fright_point.normalized()
	
	# Если точка очень близко к душе, выбираем случайное направление
	if to_fright_point.length() < 50:
		print("Точка слишком близко, выбираем случайное направление")
		var random_angle = randf() * 2 * PI
		direction_away = Vector2(cos(random_angle), sin(random_angle))
	
	# Устанавливаем направление испуга (ВЫСШИЙ ПРИОРИТЕТ)
	fright_direction = direction_away.normalized()
	current_direction = fright_direction
	target_direction = current_direction
	
	# Активируем режим испуга
	is_frightened = true
	fright_timer = 0.0
	movement_speed = 20.0
	
	print("Установлено направление испуга: ", fright_direction)
	print("Приоритет: ВЫСШИЙ (игнорируем зоны захвата)")

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
	print("=== ПРОСТОЙ ИСПУГ (ВЫСШИЙ ПРИОРИТЕТ) ===")
	fright_direction = -current_direction  # Просто разворачиваемся
	current_direction = fright_direction
	target_direction = current_direction
	
	is_frightened = true
	fright_timer = 0.0
	movement_speed = 20.0
	
	# Возвращаем нормальную скорость через время
	get_tree().create_timer(fright_duration).timeout.connect(
		func(): 
			if is_moving and is_instance_valid(self):
				movement_speed = 15.0
				is_frightened = false
	, CONNECT_ONE_SHOT)

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
