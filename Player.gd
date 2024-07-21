extends CharacterBody2D

@export var speed = 400

@onready var animation_player = $AnimationPlayer

var target = position

func _ready():
	animation_player.play("RESET")

func _input(event):
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()

func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	# look_at(target)s
	if position.distance_to(target) > 10:
		move_and_slide()

func _on_player_mouse_area_area_entered(area):
	if area.is_in_group("Enemy"):
		animation_player.play("Missing")


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Missing":
			get_tree().reload_current_scene()
