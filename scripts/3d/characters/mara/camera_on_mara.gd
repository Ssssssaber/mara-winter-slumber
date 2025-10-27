extends Button

@export var mara_reference : Node3D 

var camera_on_mara : bool = false

func _on_pressed() -> void:
	camera_on_mara = not camera_on_mara
	if camera_on_mara:
		GameManager.SetCameraTarget(mara_reference)
		text = "Camera Off Mara"
	else:
		GameManager.SetCameraTarget(null)
		text = "Camera On Mara"
	
