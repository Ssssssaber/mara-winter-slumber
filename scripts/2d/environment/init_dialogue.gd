extends Node

@onready var dialogue_scene = load("res://scenes/2d/environment/dialogue_scene.tscn")

func _ready() -> void:
    DialogueManager.start_dialogue.connect(init_dialogue_scene)
    
func init_dialogue_scene(json_path):
    var current_scene = dialogue_scene.instantiate()
    get_parent().add_child(current_scene)
    current_scene.parse_json_start_dialogue(json_path)