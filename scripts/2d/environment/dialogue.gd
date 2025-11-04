extends Control

# Ноды сцены
@onready var character_sprite = $CharacterSprite
@onready var name_label = $CharacterName
@onready var dialogue_text = $DialogueText
@onready var accept_button = $AcceptButton
@onready var decline_button = $DeclineButton
@onready var illustration_container = $IllustrationContainer  # Новый узел для иллюстрации
@onready var illustration_texture = $IllustrationContainer/IllustrationTexture  # TextureRect для картинки
@onready var mara_sprite = $Mara
@onready var text_turn = $TextTurn
@onready var sprite1 = $Sprite2D
@onready var sprite2 = $Sprite2D2
@onready var sprite3 = $Sprite2D3
@onready var sprite4 = $Sprite2D4

var _current_dialog_path : String

signal dialog_ended_with_battle(current_dialog_path : String)

# Переменные для управления диалогом
var dialogue_data: Dictionary
var current_dialogue: String = "choice_dialogue"  # Текущий диалог
var current_line: int = 0
var is_typing: bool = false
var typing_speed: float = 0.05  # Скорость появления букв
var waiting_for_battle_click: bool = false  # Флаг ожидания клика для битвы
var dialogue_playing: bool = false

# Настройки позиционирования спрайта
@export var sprite_offset: Vector2 = Vector2(-100, -100)  # Смещение относительно RichTextLabel
@export var sprite_scale: Vector2 = Vector2(0.155, 0.155)  # Масштаб спрайта


func _ready():
	print("=== ДИАЛОГ СИСТЕМА: _ready() запущен ===")
	# Скрываем кнопки выбора сначала
	choice_buttons_hide()
	
	# Подключаем сигналы кнопок
	accept_button.pressed.connect(_on_accept_pressed)
	decline_button.pressed.connect(_on_decline_pressed)
	
	# Позиционируем спрайт относительно RichTextLabel
	position_sprite_relative_to_text()
	illustration_container.hide()

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

func position_sprite_relative_to_text():
	# Позиционируем спрайт относительно правого верхнего угла RichTextLabel
	var text_global_pos = dialogue_text.global_position
	var text_size = dialogue_text.size
	
	character_sprite.global_position = Vector2(
		text_global_pos.x + text_size.x + sprite_offset.x + 250,  # Справа от текста
		text_global_pos.y - 125 # Сверху от текста
	)
	
	print("Спрайт позиционирован относительно RichTextLabel") 

func _notification(what):
	# Обновляем позицию спрайта при изменении размера окна
	if what == NOTIFICATION_RESIZED || what == NOTIFICATION_WM_SIZE_CHANGED:
		position_sprite_relative_to_text()

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
		set_illustration(dialogue.illustration)
		character_sprite.hide()  # Скрываем спрайт
		mara_sprite.hide()
		illustration_container.show()  
	
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
	dialog_ended_with_battle.emit(_current_dialog_path)
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
				text_turn.play()
				current_line += 1
				show_line(current_line)
			elif current_dialogue != "choice_dialogue":
				# Для не-choice диалогов закрываем сцену после последнего клика
				DialogueManager.EndDialogue(_current_dialog_path)
				dialogue_playing = false
				queue_free()

func set_character_sprite(sprite_path: String):
	print("Загрузка спрайта: ", sprite_path)
	
	# Пробуем загрузить через ResourceLoader
	var sprite_texture = ResourceLoader.load(sprite_path)
	if sprite_texture:
		character_sprite.texture = sprite_texture
		character_sprite.scale = sprite_scale
		position_sprite_relative_to_text()
		print("Спрайт загружен и позиционирован относительно RichTextLabel")
	else:
		# Пробуем альтернативный путь
		var alternative_path = sprite_path.replace("res://", "")
		sprite_texture = load(alternative_path)
		if sprite_texture:
			character_sprite.texture = sprite_texture
			character_sprite.scale = sprite_scale
			position_sprite_relative_to_text()
			print("Спрайт загружен через альтернативный путь")
		else:
			push_error("Не удалось загрузить спрайт: " + sprite_path)
			# Можно показать спрайт-заглушку
			show_fallback_sprite()

func set_illustration(illustration_path: String):
	print("Загрузка иллюстрации: ", illustration_path)
	
	var illustration_texture_resource = ResourceLoader.load(illustration_path)
	if illustration_texture_resource:
		illustration_texture.texture = illustration_texture_resource
		setup_illustration()
		print("Иллюстрация загружена и отмасштабирована")
	else:
		# Пробуем альтернативный путь
		var alternative_path = illustration_path.replace("res://", "")
		illustration_texture_resource = load(alternative_path)
		if illustration_texture_resource:
			illustration_texture.texture = illustration_texture_resource
			setup_illustration()
			print("Иллюстрация загружена через альтернативный путь")
		else:
			push_error("Не удалось загрузить иллюстрацию: " + illustration_path)
			# Можно показать заглушку
			show_fallback_illustration()

func setup_illustration():
	# Масштабируем иллюстрацию чтобы она вписалась в экран
	var screen_size = get_viewport().get_visible_rect().size
	var texture_size = illustration_texture.texture.get_size()
	
	var scale_x = screen_size.x * 0.8  # 80% ширины экрана
	var scale_y = screen_size.y * 0.8   # 80% высоты экрана
	var scale = min(scale_x, scale_y, 1.0)
	
	print("Скейлы: ", scale_x, " ", scale_y, " ", scale)
	illustration_texture.scale = Vector2(0.1, 0.1)
	illustration_texture.position = Vector2(dialogue_text.position.x + 1150, dialogue_text.position.y + 890)
	sprite1.show()
	sprite2.show()
	sprite3.show()
	sprite4.show()

func show_fallback_sprite():
	# Создаем простой цветной спрайт как заглушку
	var fallback_texture = ImageTexture.create_from_image(Image.create(100, 100, false, Image.FORMAT_RGBA8))
	character_sprite.texture = fallback_texture
	character_sprite.scale = sprite_scale
	position_sprite_relative_to_text()
	print("Показан спрайт-заглушка")

func show_fallback_illustration():
	# Создаем простую иллюстрацию-заглушку
	var fallback_texture = ImageTexture.create_from_image(Image.create(200, 200, false, Image.FORMAT_RGBA8))
	illustration_texture.texture = fallback_texture
	setup_illustration()
	print("Показана иллюстрация-заглушка")
