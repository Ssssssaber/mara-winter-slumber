extends HBoxContainer

func _ready():
	#Настройка кнопок
	var intimidate_btn = $IntimidateButton
	var capture_btn = $CaptureButton
	
	intimidate_btn.theme = Theme.new()
	capture_btn.theme = intimidate_btn.theme
