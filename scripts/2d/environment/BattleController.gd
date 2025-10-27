extends Node

class_name BattleController

#Ссылки на узлы
@onready var soul_area: ColorRect = get_node("../SoulArea")
@onready var soul: Soul = get_node("../SoulArea/Soul")
@onready var capture_zones_container: Node2D = get_node("../CaptureZone")
@onready var battle_text: Label = get_node("../BattleText")
@onready var soul_health_label: Label = get_node("../SoulHealth")
@onready var intimidate_btn: Button = get_node("../ActionButtons/IntimidateButton")
@onready var capture_btn: Button = get_node("../ActionButtons/CaptureButton")

# Настройки зон захвата
var capture_zone_scene: PackedScene
var zone_size: Vector2 = Vector2(100, 80)

# Состояние боя
var battle_active: bool = true
var cooldown: bool = false

# Режим размещения зоны
var is_placing_zone: bool = false
var temp_zone: Area2D = null

func _ready():
	capture_zone_scene = preload("res://scenes/2d/environment/capture_zone.tscn")
	
	intimidate_btn.pressed.connect(_on_intimidate_pressed)
	capture_btn.pressed.connect(_on_capture_pressed)
	
	add_to_group("battle_controller")
	_update_health_ui()

func _input(event):
	if is_placing_zone and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_finalize_zone_placement(event)

func _on_intimidate_pressed():
	if battle_active and not cooldown and is_instance_valid(soul):
		soul.intimidate()
		battle_text.text = "Вы запугали душу! Она меняет направление."
		_start_cooldown()

func _on_capture_pressed():
	if battle_active and not cooldown and not is_placing_zone:
		_start_zone_placement()

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
	
	# Получаем позицию мыши в глобальных координатах
	var mouse_global_pos = mouse_event.global_position
	
	# Преобразуем глобальную позицию мыши в локальную позицию внутри CaptureZones контейнера
	var local_position = capture_zones_container.get_global_transform().affine_inverse() * mouse_global_pos
	
	# Проверяем что позиция внутри SoulArea
	var area_global_rect = Rect2(soul_area.global_position, soul_area.size)
	if area_global_rect.has_point(mouse_global_pos):
		# Фиксируем позицию зоны (используем текущую позицию предпросмотра)
		# чтобы избежать смещения из-за задержки между кадрами
		temp_zone.position = temp_zone.position
		temp_zone.activate()  # Запускаем таймер захвата
		
		battle_text.text = "Зона захвата установлена! Сработает через 3 секунды."
		print("Зона захвата установлена в позиции: ", temp_zone.position)
		
		# Выходим из режима размещения
		is_placing_zone = false
		temp_zone = null
		
		# Запускаем кд
		_start_cooldown()
	else:
		battle_text.text = "Позиция вне области души! Попробуйте еще раз."

func _start_cooldown():
	cooldown = true
	intimidate_btn.disabled = true
	capture_btn.disabled = true
	
	await get_tree().create_timer(1.0).timeout
	
	if battle_active:
		cooldown = false
		intimidate_btn.disabled = false
		capture_btn.disabled = false

func _update_health_ui():
	if is_instance_valid(soul):
		soul_health_label.text = "Здоровье души: %d/%d" % [soul.current_health, soul.max_health]

func end_battle(victory: bool):
	battle_active = false
	cooldown = true
	is_placing_zone = false
	
	intimidate_btn.disabled = true
	capture_btn.disabled = true
	
	# Удаляем временную зону если она есть
	if temp_zone and is_instance_valid(temp_zone):
		temp_zone.queue_free()
		temp_zone = null
	
	# Очищаем все зоны захвата
	if is_instance_valid(capture_zones_container):
		for zone in capture_zones_container.get_children():
			if is_instance_valid(zone):
				zone.queue_free()
	
	battle_text.text = "Победа! Душа захвачена." if victory else "Поражение!"
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func _on_soul_damaged():
	_update_health_ui()
