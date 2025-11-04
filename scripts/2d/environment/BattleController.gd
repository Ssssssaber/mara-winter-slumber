extends Node

class_name BattleController

#Ссылки на узлы
@onready var soul_area: ColorRect = get_node("../SoulArea")
@onready var soul: Soul = get_node("../SoulArea/Soul")
@onready var capture_zones_container: Node2D = get_node("../CaptureZone")
@onready var battle_text: Label = get_node("../BattleText")
@onready var intimidate_btn: Button = get_node("../IntimidateButton")
@onready var capture_btn: Button = get_node("../CaptureButton")
@onready var battle_timer: Timer = get_node("../Timer")
@onready var timer_label: Label = get_node("../TimerLabel")
@onready var intimidate_animation: AnimatedSprite2D = get_node("../FrightAnimation")

@export var battle_duration: int = 20
var time_remaining: float = 0

var from_dialogue : String = ""

# Настройки зон захвата
var capture_zone_scene: PackedScene
var zone_size: Vector2 = Vector2(200, 160)

# Состояние боя
var battle_active: bool = true
var intimidate_cooldown: bool = false
var capture_cooldown: bool = false
var intimidate_cooldown_time: int = 1    # 1 секунда для испуга
var capture_cooldown_time: int = 3       # 3 секунды для захвата

# Режимы размещения
var is_placing_zone: bool = false
var is_placing_intimidate: bool = false
var temp_zone: Area2D = null
var temp_intimidate_point: Sprite2D = null

func _ready():
	capture_zone_scene = preload("res://scenes/2d/environment/capture_zone.tscn")
	
	intimidate_btn.pressed.connect(_on_intimidate_pressed)
	capture_btn.pressed.connect(_on_capture_pressed)

	if battle_timer:
		battle_timer.timeout.connect(_on_battle_timer_timeout)
	
	add_to_group("battle_controller")
	_start_battle_timer()

func _start_battle_timer():
	time_remaining = battle_duration
	if battle_timer:
		battle_timer.wait_time = battle_duration
		battle_timer.start()
	set_process(true)

func _process(delta):
	if battle_active and time_remaining > 0:
		time_remaining -=delta
		_update_timer_display()

func _update_timer_display():
	if timer_label:
		var minutes = floor(time_remaining / 60)
		var seconds = int(time_remaining) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		
		# Меняем цвет при малом времени
		if time_remaining <= 10.0:
			timer_label.add_theme_color_override("font_color", Color.RED)
		else:
			timer_label.add_theme_color_override("font_color", Color.WHITE)

func _on_battle_timer_timeout():
	if battle_active:
		print("Время вышло! Битва завершена.")
		end_battle(false)  # Поражение по таймеру

func _input(event):
	if is_placing_zone and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_finalize_zone_placement(event)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_cancel_zone_placement()
	
	elif is_placing_intimidate and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_finalize_intimidate_placement(event)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_cancel_intimidate_placement()

func _on_intimidate_pressed():
	# Проверяем кулдаун конкретно для испуга
	if battle_active and not intimidate_cooldown and not is_placing_intimidate and not is_placing_zone:
		_start_intimidate_placement()
	else:
		if intimidate_cooldown:
			print("Испуг на кулдауне!")
		elif is_placing_zone:
			print("Сначала закончите размещение зоны!")

func _on_capture_pressed():
	# Проверяем кулдаун конкретно для захвата
	if battle_active and not capture_cooldown and not is_placing_zone and not is_placing_intimidate:
		_start_zone_placement()
	else:
		if capture_cooldown:
			print("Захват на кулдауне!")
		elif is_placing_intimidate:
			print("Сначала закончите размещение испуга!")

func _start_intimidate_placement():
	is_placing_intimidate = true
	battle_text.text = "Кликните мышкой чтобы испугать душу в выбранном направлении"
	
	# Создаем точку используя тот же подход, что и для зоны захвата
	temp_intimidate_point = Sprite2D.new()
	temp_intimidate_point.set_script(preload("res://scripts//2d//environment//intimidate_point.gd"))
	
	capture_zones_container.add_child(temp_intimidate_point)
	
	print("=== РЕЖИМ РАЗМЕЩЕНИЯ ИСПУГА ===")

func _finalize_intimidate_placement(mouse_event: InputEventMouseButton):
	if not is_placing_intimidate or not temp_intimidate_point:
		return
	
	var mouse_global_pos = mouse_event.global_position
	
	print("=== ПРИМЕНЕНИЕ ИСПУГА ===")
	
	# Проверяем что позиция внутри SoulArea
	var area_global_rect = Rect2(soul_area.global_position, soul_area.size)
	if area_global_rect.has_point(mouse_global_pos):
		# Передаем глобальные координаты напрямую!
		intimidate_animation.visible = true
		intimidate_animation.position = mouse_global_pos
		intimidate_animation.play("default")
		intimidate_animation.scale = Vector2(0.1, 0.1)
		soul.intimidate_from_point(mouse_global_pos)
		
		# Визуализируем точку испуга
		temp_intimidate_point.global_position = mouse_global_pos
		
		battle_text.text = "Душа испугана! Она убегает от точки испуга."
		
		# Удаляем точку через короткое время
		var timer = get_tree().create_timer(0.9)
		await timer.timeout
		_remove_intimidate_point()
		
		is_placing_intimidate = false
		_start_intimidate_cooldown()  # Запускаем кулдаун для ИСПУГА

		intimidate_animation.stop()
		intimidate_animation.visible = false
	else:
		battle_text.text = "Позиция вне области души! Попробуйте еще раз."

func _start_intimidate_cooldown():
	intimidate_cooldown = true
	intimidate_btn.disabled = true
	
	print("Кулдаун испуга начался: ", intimidate_cooldown_time, "с")
	
	# Таймер для ИСПУГА
	var cooldown_timer = get_tree().create_timer(intimidate_cooldown_time)
	await cooldown_timer.timeout
	
	if battle_active:
		intimidate_cooldown = false
		intimidate_btn.disabled = false
		print("Кулдаун испуга закончился")

func _cancel_intimidate_placement():
	if is_placing_intimidate and temp_intimidate_point:
		_remove_intimidate_point()
		is_placing_intimidate = false
		battle_text.text = "Размещение испуга отменено"

func _remove_intimidate_point():
	if temp_intimidate_point and is_instance_valid(temp_intimidate_point):
		temp_intimidate_point.queue_free()
		temp_intimidate_point = null

func _start_zone_placement():
	is_placing_zone = true
	battle_text.text = "Кликните мышкой в области души чтобы разместить зону захвата"
	
	# Создаем временную зону для предпросмотра
	temp_zone = capture_zone_scene.instantiate()
	capture_zones_container.add_child(temp_zone)
	temp_zone.setup_preview(zone_size)
	
	print("Режим размещения зоны активирован")

func _finalize_zone_placement(mouse_event: InputEventMouseButton):
	if not is_placing_zone or not temp_zone:
		return
	
	# Используем текущую глобальную позицию зоны предпросмотра
	var final_global_pos = temp_zone.global_position
	
	# Проверяем что позиция внутри SoulArea
	var area_global_rect = Rect2(soul_area.global_position, soul_area.size)
	if area_global_rect.has_point(final_global_pos):
		# Фиксируем позицию зоны
		temp_zone.activate()
		
		battle_text.text = "Зона захвата установлена! Сработает через 3 секунды."
		print("Зона захвата установлена в глобальной позиции: ", final_global_pos)
		
		# Выходим из режима размещения
		is_placing_zone = false
		temp_zone = null
		
		_start_capture_cooldown()  # Запускаем кулдаун для ЗАХВАТА
	else:
		battle_text.text = "Позиция вне области души! Попробуйте еще раз."

func _start_capture_cooldown():
	capture_cooldown = true
	capture_btn.disabled = true
	
	print("Кулдаун захвата начался: ", capture_cooldown_time, "с")
	
	# Таймер для ЗАХВАТА
	var cooldown_timer = get_tree().create_timer(capture_cooldown_time)
	await cooldown_timer.timeout
	
	if battle_active:
		capture_cooldown = false
		capture_btn.disabled = false
		print("Кулдаун захвата закончился")

func _cancel_zone_placement():
	if is_placing_zone and temp_zone:
		temp_zone.queue_free()
		temp_zone = null
		is_placing_zone = false
		battle_text.text = "Размещение зоны отменено"


func end_battle(victory: bool):
	battle_active = false
	intimidate_cooldown = true
	capture_cooldown = true
	is_placing_zone = false
	is_placing_intimidate = false
	
	if battle_timer:
		battle_timer.stop()
	set_process(false)  # Останавливаем обновление таймера

	intimidate_btn.disabled = true
	capture_btn.disabled = true
	
	# Удаляем временные объекты
	if temp_zone and is_instance_valid(temp_zone):
		temp_zone.queue_free()
		temp_zone = null
	
	_remove_intimidate_point()
	
	# Очищаем все зоны захвата
	if is_instance_valid(capture_zones_container):
		for zone in capture_zones_container.get_children():
			if is_instance_valid(zone):
				zone.queue_free()
	
	if victory:
		print("Победа! Душа захвачена.")
		DialogueManager.EndBattle(from_dialogue)
	else:
		print("Поражение!")
		DialogueManager.EndBattleOutOfTime(from_dialogue)
	
	get_parent().queue_free()
