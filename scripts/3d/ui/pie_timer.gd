extends Node3D

@onready var pie_timer_ui : TextureProgressBar = get_node("ViewportTextureSprite/SubViewport/PieTimer")
@onready var timer : Timer = get_node("Timer")

@export var start_color : Color = Color(0, 1, 0)
@export var end_color : Color = Color(1, 0, 0)

@export var min_time : float = 10.0
@export var max_time : float = 40.0

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	timer.timeout.connect(_on_PieTimer_timeout)
	pie_timer_ui.visible = false

	start_timer(rng.randf_range(min_time, max_time)) # Example: start a 5-second timer

func start_timer(duration : float) -> void:
	timer.wait_time = duration
	timer.start()
	pie_timer_ui.value = 0
	pie_timer_ui.visible = true

func _process(_delta: float) -> void:
	if timer.time_left > 0:
		var progress = timer.time_left / timer.wait_time
		pie_timer_ui.value = (timer.time_left / timer.wait_time) * 100
		pie_timer_ui.tint_progress = Color(1.0 - progress, progress, 0.0)

func _on_PieTimer_timeout() -> void:
	pie_timer_ui.visible = false
	timer.stop()
