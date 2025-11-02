extends Node

@onready var dialogue_scene = load("res://scenes/2d/environment/dialogue_scene.tscn")
@onready var battle_scene = load("res://scenes/2d/environment/battle_scene.tscn")


func _ready() -> void:
	DialogueManager.start_dialogue.connect(init_dialogue_scene)
	DialogueManager.battle_started_without_dialogue.connect(init_battle_scene)
	
func init_dialogue_scene(json_path):
	var current_scene = dialogue_scene.instantiate()
	get_parent().add_child(current_scene)
	current_scene.dialog_ended_with_battle.connect(init_battle_scene)
	current_scene.parse_json_start_dialogue(json_path)


func init_battle_scene(current_dialogue : String):
	if battle_scene:
		var current_battle_scene = battle_scene.instantiate()
		var battle_controller = current_battle_scene.get_node("BattleController") 
		battle_controller.from_dialogue = current_dialogue
		get_parent().add_child(current_battle_scene)

	else:
		push_error("Battle scene not found at")
