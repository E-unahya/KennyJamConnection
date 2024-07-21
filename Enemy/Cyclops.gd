extends CharacterBody2D


const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var collider = move_and_collide(velocity * delta)
	if collider:
		velocity.y = SPEED
	velocity.x = SPEED
	move_and_slide()
