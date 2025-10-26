extends Node3D

@onready var pie_timer_ui : TextureProgressBar = get_node("ViewportTextureSprite/SubViewport/PieTimer")
@onready var timer : Timer = get_node("Timer")

func _ready() -> void:
	timer.timeout.connect(_on_PieTimer_timeout)
	pie_timer_ui.visible = false

	start_timer(5.0) # Example: start a 5-second timer

func start_timer(duration : float) -> void:
	timer.wait_time = duration
	timer.start()
	pie_timer_ui.value = 0
	pie_timer_ui.visible = true

func _process(_delta: float) -> void:
	if timer.time_left > 0:
		pie_timer_ui.value = (timer.time_left / timer.wait_time) * 100

func _on_PieTimer_timeout() -> void:
	pie_timer_ui.visible = false
