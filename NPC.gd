extends CharacterBody2D

signal clear

func _on_area_2d_body_entered(body):
	if body.name == "Present":
		clear.emit()
