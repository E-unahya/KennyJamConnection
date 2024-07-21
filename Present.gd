extends Path2D

@onready var path_follow_2d : PathFollow2D = $PathFollow2D
var go : bool

func _ready():
	go = false

func _process(delta):
	if go:
		path_follow_2d.progress_ratio += path_follow_2d.get_progress() + delta * 0.2


func _go():
	go = true
