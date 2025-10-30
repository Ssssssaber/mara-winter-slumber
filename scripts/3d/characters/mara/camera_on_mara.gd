extends Button

@export var mara_reference : Node3D 
@export var camera_on_mara : bool = false

func _ready() -> void:
	update_button(camera_on_mara)

func _on_pressed() -> void:
	camera_on_mara = not camera_on_mara
	update_button(camera_on_mara)
	
func update_button(state : bool) -> void:
	if state:
		GameManager.SetCameraTarget(mara_reference)
		text = "Camera Off Mara"
	else:
		GameManager.SetCameraTarget(null)
		text = "Camera On Mara"
	