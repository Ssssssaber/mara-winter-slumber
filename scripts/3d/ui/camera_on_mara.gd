extends Button

@export var mara_reference : Node3D 
@export var camera_on_mara : bool = false

func _init() -> void:
	GameManager.OnGameManagerReady.connect(update_button)

func update_button() -> void:
	_update_button(camera_on_mara)

func _on_pressed() -> void:
	camera_on_mara = not camera_on_mara
	_update_button(camera_on_mara)
	
func _update_button(state : bool) -> void:
	if state:
		GameManager.SetCameraTarget(mara_reference)
		text = "Camera Off Mara"
	else:
		GameManager.SetCameraTarget(null)
		text = "Camera On Mara"
	
