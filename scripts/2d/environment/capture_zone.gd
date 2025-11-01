extends Area2D

class_name CaptureZone

# Настройки зоны
var zone_size: Vector2 = Vector2(200, 160)
var activation_time: float = 3.0
var is_active: bool = false
var has_triggered: bool = false
var is_preview: bool = false

# Визуальные элементы
@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

var countdown_label: Label


func _ready():
	# Базовая настройка
	_setup_collision()
	_setup_visual()
	
	# Подключаем сигналы
	timer.timeout.connect(_on_timer_timeout)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
	print("Объект вошел в зону захвата: ", area.name, " тип: ", area.get_class())
	if area.is_in_group("soul"):
		print("Душа вошла в зону захвата!")

func _on_area_exited(area: Area2D):
	print("Объект вышел из зоны захвата: ", area.name)

# Функция для предпросмотра (режим размещения)
func setup_preview(size: Vector2):
	zone_size = size
	is_preview = true
	_update_collision()
	_update_visual()
	
	# Для предпросмотра делаем полупрозрачной и без коллизии
	color_rect.color = Color(0, 1, 0, 0.3)  # Зеленая для предпросмотра
	collision_shape.disabled = true

func _process(delta):
	if is_preview:
		# Получаем позицию мыши в локальных координатах родителя
		var mouse_pos = get_global_mouse_position()
		var local_mouse_pos = get_parent().get_global_transform().affine_inverse() * mouse_pos
		
		# Устанавливаем позицию зоны
		position = local_mouse_pos

# Функция активации зоны после размещения
func activate():
	is_preview = false
	set_process(false)  # Прекращаем следить за мышкой
	
	# Включаем коллизию
	collision_shape.disabled = false
	
	# Обновляем визуал на боевой режим
	_update_visual()
	_start_countdown()
	_notify_soul_about_zone()
	
	print("Зона захвата активирована, таймер запущен. Позиция: ", global_position)

func _notify_soul_about_zone():
	var souls = get_tree().get_nodes_in_group("soul")
	for soul in souls:
		if soul.has_method("add_capture_zone"):
			soul.add_capture_zone(self)

func _setup_collision():
	var shape = RectangleShape2D.new()
	shape.size = zone_size
	collision_shape.shape = shape
	collision_shape.disabled = true  # Изначально выключена

func _update_collision():
	if collision_shape and collision_shape.shape:
		collision_shape.shape.size = zone_size

func _setup_visual():
	if color_rect:
		color_rect.size = zone_size
		color_rect.position = -zone_size / 2  # Центрируем

func _update_visual():
	if not color_rect:
		return
		
	color_rect.size = zone_size
	color_rect.position = -zone_size / 2
	
	if is_preview:
		# Зеленая полупрозрачная для предпросмотра
		color_rect.color = Color(0, 1, 0, 0.3)
	elif not is_active and not has_triggered:
		# Желтый - готовится к активации
		color_rect.color = Color(1, 1, 0, 0.3)
		_start_pulse_animation()
	elif is_active:
		# Красный - активна и наносит урон
		color_rect.color = Color(1, 0, 0, 0.8)
	else:
		# Серый - уже сработала
		color_rect.color = Color(0.5, 0.5, 0.5, 0.2)

func _start_pulse_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(color_rect, "color", Color(1, 0.8, 0, 0.5), 0.5)
	tween.tween_property(color_rect, "color", Color(1, 1, 0, 0.3), 0.5)

func _start_countdown():
	# Создаем label для отсчета времени если его нет
	if not countdown_label:
		countdown_label = Label.new()
		countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		countdown_label.add_theme_font_size_override("font_size", 20)
		countdown_label.add_theme_color_override("font_color", Color.WHITE)
		add_child(countdown_label)
		countdown_label.position = -zone_size / 2
		countdown_label.size = zone_size
	
	# Запускаем таймер
	timer.wait_time = activation_time
	timer.start()
	
	# Запускаем анимацию отсчета
	_start_countdown_animation()

func _start_countdown_animation():
	var time_left = activation_time
	while time_left > 0 and is_inside_tree() and not has_triggered:
		if countdown_label:
			countdown_label.text = str(ceil(time_left))
		await get_tree().create_timer(1.0).timeout
		time_left -= 1.0
	
	if countdown_label and is_inside_tree():
		countdown_label.text = "!"

func _on_timer_timeout():
	if not has_triggered:
		is_active = true
		_update_visual()
		print("Зона захвата сработала! Проверка души в зоне...")
		
		# Проверяем, находится ли душа в зоне
		var overlapping_areas = get_overlapping_bodies()
		print("Количество объектов в зоне: ", overlapping_areas.size())
		
		var soul_found = false
		for area in overlapping_areas:
			print("Проверка объекта: ", area.name, " тип: ", area.get_class())
			if area.is_in_group("soul"):
				print("Душа найдена в зоне! Наносим урон...")
				_capture_soul(area)
				soul_found = true
		
		if not soul_found:
			print("Душа не найдена в зоне захвата")
		
		# Деактивируем через короткое время
		await get_tree().create_timer(0.5).timeout
		is_active = false
		has_triggered = true
		_update_visual()

		_remove_zone_from_soul()
		
		# Удаляем через 1 секунду после срабатывания
		await get_tree().create_timer(1.0).timeout
		if is_inside_tree():
			queue_free()

func _remove_zone_from_soul():
	var souls = get_tree().get_nodes_in_group("soul")
	for soul in souls:
		if soul.has_method("remove_capture_zone"):
			soul.remove_capture_zone(self)

func _capture_soul(soul: Node):
	print("Попытка нанести урон душе...")
	if soul.has_method("take_damage"):
		print("Метод take_damage найден, вызываем...")
		var result = soul.take_damage()
		print("Результат take_damage: ", result)
	else:
		print("ОШИБКА: Метод take_damage не найден у объекта ", soul.name)
