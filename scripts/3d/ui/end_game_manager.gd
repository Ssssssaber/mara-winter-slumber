extends Control

@export var ending_label : Label
@export var ending_text : Label

func set_ending_text(ending_name : String, ending_description : String) -> void:
	ending_label.text = "КОНЦОВКА: " + ending_name
	ending_text.text = ending_description
