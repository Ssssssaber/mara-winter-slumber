extends Control

@onready var monologue_text = $MonologueText

var text_lines: Array
var current_line: int = 1
var is_typing: bool = false
var typing_speed: float = 0.05

func _ready():
	print("=== МОНОЛОГ: Сцена запущена ===")
	
	# Начинаем показ текста
	show_current_line()
	#show_monologue(text_to_display)

# Функция для установки текста извне
func set_monologue_text(text: Array):
	text_lines = text

func show_current_line():
	if current_line >= text_lines.size():
		return
	
	var line = text_lines[current_line]
	print("Показ строки ", current_line, ": ", line)
	monologue_text.text = ""
	is_typing = true
	await type_text(line)

	is_typing = false
	current_line += 1

	# После завершения анимации проверяем, была ли это последняя строка
	if current_line >= text_lines.size():
		print("Все строки показаны, ждем клик для закрытия")

func type_text(text: String):
	monologue_text.text = ""
	for i in range(text.length()):
		if !is_typing:  # Если прервали анимацию
			monologue_text.text = text
			break
		monologue_text.text += text[i]
		await get_tree().create_timer(typing_speed).timeout

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Клик в монологе, текущая строка: ", current_line)

		if is_typing:
			# Пропускаем анимацию текста текущей строки
			is_typing = false
		else:
			if current_line < text_lines.size():
				# Переходим к следующей строке
				show_current_line()
			else:
				# Все строки показаны - закрываем сцену
				print("Закрываем монолог")
				queue_free()
