extends Node

# @export var mara_progress : float = 0.0
# @export var ghost_progress : float = 0.0

@export var mara_inverted : bool = 0.0
@export var ghost_inverted : bool = 0.0

@export var mara : Node3D
@export var ghost : Node3D 

func _init() -> void:
	GameManager.OnGameManagerReady.connect(setup)

func setup() -> void:
	print("Setup game scenario")
	GameManager.AddEntityToPathAutoProgress(mara, mara_inverted)
	GameManager.AddEntityToPathAutoProgress(ghost, ghost_inverted)