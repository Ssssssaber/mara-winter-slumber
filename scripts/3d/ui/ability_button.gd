extends Button

@onready var progress_bar : ProgressBar = get_node("AbilityCooldownProgress")

signal ability_pressed()

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func set_current_progress(progress : float) -> void:
	# print(name, progress)
	progress_bar.value = progress

func _on_button_pressed() -> void:
	ability_pressed.emit()
