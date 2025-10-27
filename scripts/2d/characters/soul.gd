extends CharacterBody2D

class_name Soul

# Настройки движения
var movement_speed: float = 15.0
var current_direction: Vector2 = Vector2.ZERO
var is_moving: bool = true

# Здоровье
var max_health: int = 2
var current_health: int = max_health
var health_bar: ProgressBar

# Ссылки
@onready var soul_area: ColorRect = get_parent()

func _ready():
	# Добавляем душу в группу для идентификации
	add_to_group("soul")
	
	# Устанавливаем начальную позицию в центре области
	position = soul_area.size / 2
	
	# Устанавливаем случайное начальное направление
	_set_random_direction()
	
	# Создаем health bar
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(50, 8)
	health_bar.min_value = 0
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_child(health_bar)
	health_bar.position = Vector2(-25, -25)  # Над душой

func _physics_process(delta):
	if is_moving:
		_move_soul(delta)

func _set_random_direction():
	# Генерируем случайное направление
	var random_angle = randf() * 2 * PI  # Случайный угол от 0 до 2π
	current_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
	print("Начальное направление души: ", current_direction)

func _move_soul(delta):
	velocity = current_direction * movement_speed
	
	# Получаем границы области души
	var area_rect = soul_area.get_rect()
	var soul_size = Vector2(16, 16)  # Размер души
	
	# Проверяем столкновение с границами
	var new_position = position + velocity * delta
	
	var bounced = false
	
	# Проверяем левую и правую границы
	if new_position.x <= 0:
		current_direction.x = abs(current_direction.x)  # Отскакиваем вправо
		new_position.x = 0
		bounced = true
	elif new_position.x >= area_rect.size.x - soul_size.x:
		current_direction.x = -abs(current_direction.x)  # Отскакиваем влево
		new_position.x = area_rect.size.x - soul_size.x
		bounced = true
	
	# Проверяем верхнюю и нижнюю границы
	if new_position.y <= 0:
		current_direction.y = abs(current_direction.y)  # Отскакиваем вниз
		new_position.y = 0
		bounced = true
	elif new_position.y >= area_rect.size.y - soul_size.y:
		current_direction.y = -abs(current_direction.y)  # Отскакиваем вверх
		new_position.y = area_rect.size.y - soul_size.y
		bounced = true
	
	# Если произошел отскок, можно добавить небольшую случайность
	if bounced:
		_add_bounce_randomness()
	
	position = new_position
	move_and_slide()

func _add_bounce_randomness():
	# Добавляем небольшую случайность при отскоке чтобы движение было менее предсказуемым
	var random_variation = 0.1  # 10% случайности
	current_direction.x += (randf() - 0.5) * 2 * random_variation
	current_direction.y += (randf() - 0.5) * 2 * random_variation
	current_direction = current_direction.normalized()

func intimidate():
	# Запугивание - меняем направление на противоположное
	current_direction *= -1
	print("Запугивание! Направление изменено на: ", current_direction)

func take_damage() -> bool:
	if current_health > 0:
		current_health -= 1
		health_bar.value = current_health
		
		# Визуальный эффект получения урона
		_flash_red()
		
		print("Душа получила урон! Здоровье: ", current_health)
		
		# Уведомляем BattleController об изменении здоровья
		get_tree().call_group("battle_controller", "_on_soul_damaged")
		
		if current_health <= 0:
			_on_death()
		
		return true
	return false

func _flash_red():
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		var original_color = sprite.modulate
		sprite.modulate = Color.RED
		
		# Создаем tween для плавного возврата цвета
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", original_color, 0.3)

func _on_death():
	is_moving = false
	velocity = Vector2.ZERO
	print("Душа побеждена!")
	get_tree().call_group("battle_controller", "end_battle", true)

func get_rect() -> Rect2:
	var soul_size = Vector2(16, 16)
	return Rect2(position - soul_size / 2, soul_size)
