extends CharacterBody2D

signal clear
@onready var animation_player = $AnimationPlayer

func _on_area_2d_body_entered(body):
	if body.name == "Present":
		animation_player.play("Clear")


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Clear":
			clear.emit()
