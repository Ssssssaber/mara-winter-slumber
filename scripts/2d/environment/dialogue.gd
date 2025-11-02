extends Control

# Ноды сцены
@onready var character_sprite = $CharacterSprite
@onready var name_label = $CharacterName
@onready var dialogue_text = $DialogueText
@onready var accept_button = $AcceptButton
@onready var decline_button = $DeclineButton

@export var test_mode: bool = true
@export var test_json_path: String = "res://assets/2d/dialogues/test_dialogue.json"

var _current_dialog_path : String

signal dialog_ended_with_battle()

# Переменные для управления диалогом
var dialogue_data: Dictionary
var current_dialogue: String = "choice_dialogue"  # Текущий диалог
var current_line: int = 0
var is_typing: bool = false
var typing_speed: float = 0.05  # Скорость появления букв
var waiting_for_battle_click: bool = false  # Флаг ожидания клика для битвы
var dialogue_playing: bool = false


func _ready():
	print("=== ДИАЛОГ СИСТЕМА: _ready() запущен ===")
	# Скрываем кнопки выбора сначала
	choice_buttons_hide()
	
	# Подключаем сигналы кнопок
	accept_button.pressed.connect(_on_accept_pressed)
	decline_button.pressed.connect(_on_decline_pressed)

func parse_json_start_dialogue(dialogue_json_path: String):
	if dialogue_playing:
		return
	
	var file = FileAccess.open(dialogue_json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		print(dialogue_json_path)
		print("Содержимое JSON: ", json_text)
		
		# Используем JSON.parse_string вместо JSON.new().parse()
		var parse_result = JSON.parse_string(json_text)
		if parse_result != null:
			dialogue_data = parse_result
			print("JSON успешно распарсен: ", dialogue_data)
			print("Ключи в словаре: ", dialogue_data.keys())
			_current_dialog_path = dialogue_json_path
			start_dialogue()
		else:
			push_error("Ошибка парсинга JSON")
	else:
		push_error("Не удалось открыть файл: " + test_json_path)


func choice_buttons_hide():
	accept_button.hide()
	decline_button.hide()

func choice_buttons_show():
	accept_button.show()
	decline_button.show()

func start_dialogue():
	dialogue_playing = true
	if dialogue_data.is_empty():
		push_error("Dialogue data not set!")
		return
	
	# Начинаем с выбора диалога
	current_dialogue = "choice_dialogue"
	current_line = 0
	show_current_dialogue()

func show_current_dialogue():
	var dialogue = dialogue_data[current_dialogue]
	print("Показ диалога: ", current_dialogue)
	
	# Устанавливаем спрайт/иллюстрацию и имя персонажа
	if dialogue.has("character_sprite"):
		set_character_sprite(dialogue.character_sprite)
	elif dialogue.has("illustration"):
		set_character_sprite(dialogue.illustration)
	
	name_label.text = dialogue.character_name
	
	# Показываем первую строку текущего диалога
	show_line(current_line)

func show_line(line_index: int):
	var dialogue = dialogue_data[current_dialogue]
	
	if line_index >= dialogue.dialogue_lines.size():
		# Диалог закончен
		if current_dialogue == "choice_dialogue":
			# Показываем кнопки выбора только в основном диалоге
			choice_buttons_show()
		else:
			# Для других диалогов - закрываем сцену после последней строки
			await get_tree().create_timer(1.0).timeout
			queue_free()
		return
	
	var line = dialogue.dialogue_lines[line_index]
	print("Текст строки: ", line)
	dialogue_text.text = ""
	is_typing = true
	await type_text(line)
	
	# После завершения анимации текста проверяем, была ли это последняя реплика
	if current_line == dialogue.dialogue_lines.size() - 1:
		if current_dialogue == "choice_dialogue":
			print("Это была последняя реплика, показываем кнопки")
			choice_buttons_show()

func type_text(text: String):
	dialogue_text.text = ""
	for i in range(text.length()):
		if !is_typing:  # Если прервали анимацию
			dialogue_text.text = text
			break
		dialogue_text.text += text[i]
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false

func _on_accept_pressed():
	var choice_dialogue = dialogue_data["choice_dialogue"]
	var accept_data = choice_dialogue.accept_response
	
	# Показываем ответ согласия
	dialogue_text.text = accept_data.answer
	choice_buttons_hide()
	
	# Обрабатываем следующий шаг
	handle_next_step(accept_data.next)

func _on_decline_pressed():
	var choice_dialogue = dialogue_data["choice_dialogue"]
	var decline_data = choice_dialogue.decline_response
	
	# Показываем ответ отказа
	dialogue_text.text = decline_data.answer
	choice_buttons_hide()
	
	# Обрабатываем следующий шаг
	handle_next_step(decline_data.next)

func handle_next_step(next_step: String):
	print("Следующий шаг: ", next_step)
	
	match next_step:
		"FIGHT":
			# Ждем клик для начала битвы
			waiting_for_battle_click = true
		"agreed":
			# Переходим к диалогу согласия
			current_dialogue = next_step
			current_line = 0
			show_current_dialogue()
		_:
			# Если неизвестный next, просто закрываем сцену
			await get_tree().create_timer(2.0).timeout
			queue_free()

func start_battle():
	waiting_for_battle_click = false

	dialog_ended_with_battle.emit()
	queue_free()

func _input(event):
	if not dialogue_playing:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if waiting_for_battle_click:
			# Если ждем клик для битвы - запускаем битву
			start_battle()
			return
		
		if is_typing:
			is_typing = false
		else:
			var dialogue = dialogue_data[current_dialogue]
			if current_line < dialogue.dialogue_lines.size() - 1:
				current_line += 1
				show_line(current_line)
			elif current_dialogue != "choice_dialogue":
				# Для не-choice диалогов закрываем сцену после последнего клика
				DialogueManager.EndDialogue(_current_dialog_path)
				dialogue_playing = false
				queue_free()

func set_character_sprite(sprite_path: String):
	print("Загрузка спрайта: ", sprite_path)
	
	if not FileAccess.file_exists(sprite_path):
		push_error("Спрайт не найден: " + sprite_path)
		return
	
	var sprite_texture = load(sprite_path)
	if sprite_texture:
		character_sprite.texture = sprite_texture
		
		# Получаем размеры экрана
		var screen_size = get_viewport().get_visible_rect().size
		
		# Настраиваем масштаб (пример)
		character_sprite.scale = Vector2(0.087, 0.087)
		
		# Позиционируем в правом верхнем углу с отступами
		var sprite_size = sprite_texture.get_size() * character_sprite.scale
		character_sprite.position = Vector2(
			screen_size.x - sprite_size.x - 75,  # Отступ 80 пикселей от правого края
			-50  # Отступ 50 пикселей от верхнего края
		)
		
		print("Спрайт позиционирован в правом верхнем углу")
	else:
		push_error("Не удалось загрузить спрайт: " + sprite_path)

func load_test_dialogue():
	print("Загрузка тестового диалога из: ", test_json_path)
	
	if not FileAccess.file_exists(test_json_path):
		push_error("Файл не существует: " + test_json_path)
		return
	
	var file = FileAccess.open(test_json_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		print("Содержимое JSON: ", json_text)
		
		# Используем JSON.parse_string вместо JSON.new().parse()
		var parse_result = JSON.parse_string(json_text)
		if parse_result != null:
			dialogue_data = parse_result
			print("JSON успешно распарсен: ", dialogue_data)
			print("Ключи в словаре: ", dialogue_data.keys())
			start_dialogue()
		else:
			push_error("Ошибка парсинга JSON")
	else:
		push_error("Не удалось открыть файл: " + test_json_path)
