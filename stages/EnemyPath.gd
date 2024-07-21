extends Path2D

@export var speed : float = 0.01
@onready var enemy_path_follow = $EnemyPathFollow

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_path_follow.progress = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enemy_path_follow.progress_ratio += enemy_path_follow.get_progress_ratio() * speed
