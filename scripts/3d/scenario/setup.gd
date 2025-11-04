extends Node

@export_category("General")
@export var dialogue_choices_handler : Node

@export_category("Setup")
@export var mara : Node3D
@export var mara_inverted : bool = 0.0
@export var ghost : Node3D 
@export var ghost_inverted : bool = 0.0

@export_category("Trigger areas")
@export var first_home_area : Area3D
@export var ghost_ignore_area : Area3D
@export var second_home_timer_area : Area3D
@export var change_direction_area : Area3D
@export var speed_up_area : Area3D
@export var third_home_area : Area3D
@export var evil_ghost_area : Area3D
@export var tree_event_area : Area3D

@export_category("Event Node References")
@export var first_home : Node3D
@export var first_home_until_death : float = 15
@export var second_home : Node3D
@export var second_home_until_death : float = 25
@export var pre_third_home : Node3D
@export var third_home : Node3D
@export var third_home_until_death : float = 40
@export var fourth_home : Node3D
@export var fourth_home_until_death : float = 40

@export_category("Evil ghost event")
@onready var evil_ghost_scene = load("res://scenes/3d/characters/ghosts/evil_ghost.tscn")
@export var spawn_point : Node3D

@export_category("Special tree event")
@export var special_tree : Node3D

func _init() -> void:
	GameManager.OnGameManagerReady.connect(setup)

func disable_all_trigger_areas() -> void:
	first_home_area.set_deferred("monitorable", false)
	ghost_ignore_area.set_deferred("monitorable", false)
	second_home_timer_area.set_deferred("monitorable", false)
	change_direction_area.set_deferred("monitorable", false)
	speed_up_area.set_deferred("monitorable", false)
	third_home_area.set_deferred("monitorable", false)
	evil_ghost_area.set_deferred("monitorable", false)
	tree_event_area.set_deferred("monitorable", false)

func setup() -> void:
	dialogue_choices_handler.evil_ghost_trigger_activate.connect(func act_tree(): evil_ghost_area.monitoring = true)
	dialogue_choices_handler.special_tree_trigger_activate.connect(func act_tree(): tree_event_area.monitoring = true)
	
	first_home_area.body_entered.connect(_on_first_home_area)
	ghost_ignore_area.body_entered.connect(_on_ghost_ignore_area)
	second_home_timer_area.body_entered.connect(_on_second_home_timer_area)
	change_direction_area.body_entered.connect(_on_change_direction_area)
	speed_up_area.body_entered.connect(_on_speed_up_area)
	third_home_area.body_entered.connect(_on_third_home_area)
	evil_ghost_area.body_entered.connect(_on_evil_ghost_area)
	tree_event_area.body_entered.connect(_on_tree_event_area)

	dialogue_choices_handler.start_last_home.connect(_on_start_last_home)

	GameManager.AddEntityToPathAutoProgress(mara, mara_inverted)
	GameManager.AddEntityToPathAutoProgress(ghost, ghost_inverted)

func _on_first_home_area(_body : Node3D) -> void:
	DialogueManager.StartOneLineDialogue(["Похоже, сегодня мне придется поработать..."])
	first_home_area.set_deferred("monitoring", false)
	first_home.pie_timer.start_timer(first_home_until_death)

func _on_ghost_ignore_area(_body : Node3D) -> void:
	ghost_ignore_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Нужно пройти сквозь привидение, чтобы успеть. (Клавиша \"X\")"])

func _on_second_home_timer_area(_body : Node3D) -> void:
	second_home_timer_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Похоже, что еще одной душе пора найти покой."])
	second_home.pie_timer.start_timer(second_home_until_death)
	speed_up_area.monitoring = true

func _on_change_direction_area(_body : Node3D) -> void:
	change_direction_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Чтобы быстрее дойти до того дома, нужно пойти обратно. (Клавиша \"С\")"])

func _on_speed_up_area(_body : Node3D) -> void:
	speed_up_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Надо ускориться, чтобы успеть. (Клавиша \"V\")"])

func _on_third_home_area(_body : Node3D) -> void:
	third_home_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Еще одну душу нужно упокоить."])
	pre_third_home.pie_timer.start_timer(third_home_until_death)
	third_home.pie_timer.start_timer(third_home_until_death)

func _on_evil_ghost_area(_body : Node3D) -> void:
	evil_ghost_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Мстительная тень преследует меня.", "Пока нет времени с ней разбираться, буду ее избегать."])
	var evil_ghost = evil_ghost_scene.instantiate()

	get_tree().root.add_child(evil_ghost)
	evil_ghost.global_transform.origin = spawn_point.global_transform.origin
	GameManager.AddEntityToPathAutoProgress(evil_ghost)

func _on_tree_event_area(_body : Node3D) -> void:
	tree_event_area.set_deferred("monitoring", false)
	DialogueManager.StartOneLineDialogue(["Похоже, дерево выросло. Сила, которую я вложила в нее, теперь помогает мне ходить быстрее."])
	if special_tree:
		special_tree.activated = true
		special_tree.visible = true

func _on_start_last_home() -> void:
	DialogueManager.StartOneLineDialogue(["Чую я, что это последняя душа на сегодня.."])
	fourth_home.pie_timer.start_timer(fourth_home_until_death)
