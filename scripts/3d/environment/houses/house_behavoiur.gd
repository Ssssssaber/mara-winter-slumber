extends Node3D

class_name HouseBehaviour

@export var json_dialogue_path : String = Constants.TEST_DIALOG_PATH

@onready var pie_timer : Node3D = get_node("PieTimerWorld")
@onready var interaction_area : Area3D = get_node("Area3D")

@onready var ok_mesh : Node3D = get_node_or_null("HouseStates/Ok")
@onready var abandoned_mesh : Node3D = get_node_or_null("HouseStates/Abandoned")

var attached_entities : Array[Node3D] = []

@export var is_abandoned : bool = false:
	set(new_value):
		is_abandoned = new_value
		_update_abandoned_state(is_abandoned)
	get:
		return is_abandoned

func _update_abandoned_state(abandoned : bool) -> void:
	if (not ok_mesh) or (not abandoned_mesh):
		return

	ok_mesh.visible = !abandoned
	abandoned_mesh.visible = abandoned
	if abandoned:
		free_attached_entities()
		if (GameManager.Initialized):
			_spawn_ghost_near_self()

func _ready() -> void:
	interaction_area.body_entered.connect(_on_area_3d_body_entered)
	pie_timer.timer.timeout.connect(_on_pie_timer_timeout)
	# _spawn_ghost_near_self()
	_update_abandoned_state(is_abandoned)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if pie_timer.get_running():
		return

	print("House entered by: ", body.name)
	pie_timer.stop_timer()

	GameManager.pause_world_entities.emit()
	_connect_to_dialog_manager()

	if json_dialogue_path == "" or json_dialogue_path == Constants.LAST_BATTLE_ID:
		DialogueManager.StartBattleWithoutDialogue(json_dialogue_path)
		return

	DialogueManager.StartDialogue(json_dialogue_path)

func _connect_to_dialog_manager() -> void:
	DialogueManager.battle_ended_out_of_time.connect(_on_battle_out_of_time)
	DialogueManager.battle_ended.connect(_disconnect_from_battle_out_of_time)
	DialogueManager.dialogue_ended.connect(_disconnect_from_battle_out_of_time)

func _disconnect_from_battle_out_of_time(_json_path : String) -> void:
	if DialogueManager.battle_ended_out_of_time.is_connected(_on_battle_out_of_time):
		return
	
	DialogueManager.battle_ended_out_of_time.disconnect(_on_battle_out_of_time)

func _on_battle_out_of_time(_json_path : String) -> void:
	is_abandoned = true

func _spawn_ghost_near_self() -> void:
	var ghost = GameManager.SpawnGhost()
	var near_house_progress = GameManager.GetMainPathProgress(self)
	GameManager.AddEntityToPath(ghost, near_house_progress, randi() % 2 == 0)

func _on_pie_timer_timeout() -> void:
	is_abandoned = true

func add_attached_entity(entity: Node3D) -> void:
	attached_entities.append(entity)

func free_attached_entities() -> void:
	for entity in attached_entities:
		if is_instance_valid(entity):
			entity.queue_free()
	attached_entities.clear()
