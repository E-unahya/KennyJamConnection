extends Node2D

@export_file("*.tscn") var next_scene : String

## タイルマップはタイルマップだ、それ以上でもそれ以下でもない
@onready var tile_map = $TileMap
## ここからセットするレールを選択する
@onready var rails = $Player/Rails

@onready var player = $Player

@onready var target = $Target

# スタートの人
@onready var start_man = $StartMan

# ゴールの人
@onready var goal = $Goal

## プレイヤーがマウスの中に入ったことを知らせる
var player_mouse_entered : bool

## あんまり良くないと思うんだけどTweenが完璧に終わったことを示す変数を宣言
var tween_finished : bool

## また新しく段階を踏んでクリックすることになってしまう
## セットしたいタイルのデータ
var set_tile_data : Vector2i

## レールの種類の情報を取得
@onready var up = $Player/Rails.get_child(0)
@onready var down = $Player/Rails.get_child(1)
@onready var right = $Player/Rails.get_child(2)
@onready var left = $Player/Rails.get_child(3)

## 何をすべきかを示すアニメーションを表示
@onready var mouse_animation = $Camera2D/MouseAnimation


var rail_shurui : Dictionary

func _ready():
	set_tile_data = Vector2i(7, 5)
	rail_shurui = {
		"UP": up.get_meta("AtlasCoodies", null),
		"DOWN":down.get_meta("AtlasCoodies", null),
		"RIGHT":right.get_meta("AtlasCoodies", null),
		"LEFT":left.get_meta("AtlasCoodies", null),
	}
	mouse_animation.play("LeftClick")
	player_mouse_entered = false
	tween_finished = false
	rails.modulate = Color(1,1,1,0)
	for i in rails.get_children():
		i.get_child(0).input_event.connect(_on_rail_sprite_mouse_entered.bind(i))
		i.get_child(0).set_process_unhandled_input(false)


func _process(delta):
	var tile_pos : Vector2i = tile_map.local_to_map(tile_map.get_global_mouse_position())
	target.position = tile_pos * tile_map.tile_set.tile_size

func _input(event):
	if event.is_action_pressed("click") and player_mouse_entered:
		set_rail(set_tile_data)
		# pick_up_rails()
	# if event.is_action_released("right_click") and set_tile_data != Vector2i(-1, -1):
		# set_rail(set_tile_data)


func pick_up_rails():
	player.set_process_input(false)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.finished.connect(_on_rails_sprite_tween_finished)
	# 透明から不透明へ
	tween.tween_property(rails, "modulate", Color(1,1,1,1), 0.3).set_trans(Tween.TRANS_CUBIC)
	# 上下左右にポップアップ
	tween.tween_property(up, 'position', 16 * Vector2.UP, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(down, 'position', 16 * Vector2.DOWN, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(right, 'position', 16 * Vector2.RIGHT, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(left, 'position', 16 * Vector2.LEFT, 0.3).set_trans(Tween.TRANS_CUBIC)


## レールをしまう関数
func pick_up_rails_reverse():
	"""
	広がったレールを戻す関数
	"""
	player.set_process_input(true)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	# 透明から不透明へ
	tween.tween_property(rails, "modulate", Color(1,1,1,0), 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(up, 'position', Vector2.ZERO, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(down, 'position', Vector2.ZERO, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(right, 'position', Vector2.ZERO, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(left, 'position', Vector2.ZERO, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween_finished = false


func set_rail(choice_rail : Vector2i) -> void:
	var tile_pos : Vector2i = tile_map.local_to_map(tile_map.get_global_mouse_position())
	## 上下左右のタイルの情報を取得
	var tile_info : Dictionary = get_tile_info(tile_pos)
	var kore = {
		Vector2i(7,5) : Vector2i(9, 6),
		Vector2i(9,6) : Vector2i(9, 6),
		Vector2i(8,5) : Vector2i(11, 6),
		Vector2i(11, 6):Vector2i(11, 6),
		Vector2i(7,6) : Vector2i(10, 5),
		Vector2i(8,6) : Vector2i(10, 5),
		Vector2i(10, 5) : Vector2i(10, 5)
	}
	var rail_address = {}
	## もし何かレールの情報を取得したときに適切なレールを設置したいなぁ
	for t in tile_info.keys():
		if tile_info[t] != Vector2i(-1, -1):
			rail_address[t] = tile_info[t]
		if tile_info[t] == choice_rail or tile_info[t] == kore[choice_rail]:
			# タイルインフォで取得した情報を何とかして
			var tile_info02 = get_tile_info(tile_pos + t)
			# デバッグ用のメソッド
			# check_tile_info(tile_info02)
			choice_rail = kore[tile_info[t]]
	print(rail_address)
	## 上にレールがあるならこれ、左にレールがあるならそれ！
	## 右にレールがあるなら()、左にレールがあるなら()といった感じに進めたい
	## 上になんかあったら
	## 正直何とかしたいコード、誰か助けて
	if rail_address.has(Vector2i.UP):
		if rail_address[Vector2i.UP] == Vector2i(7,5) or rail_address[Vector2i.UP] == Vector2i(9,6):
			if rail_address.has(Vector2i.LEFT):
				if rail_address[Vector2i.LEFT] == Vector2i(7,6) or rail_address[Vector2i.LEFT] == Vector2i(10,5):
					choice_rail = Vector2i(11, 7)
			if rail_address.has(Vector2i.RIGHT):
				if rail_address[Vector2i.RIGHT] == Vector2i(8,6) or rail_address[Vector2i.RIGHT] == Vector2i(8,6):
					choice_rail = Vector2i(9,7)
	if rail_address.has(Vector2i.DOWN):
		if rail_address[Vector2i.DOWN] == Vector2i(8, 5) or rail_address[Vector2i.DOWN] == Vector2i(9, 6):
			if rail_address.has(Vector2i.LEFT):
				if rail_address[Vector2i.LEFT] == Vector2i(7,6) or rail_address[Vector2i.LEFT] == Vector2i(10,5) or rail_address[Vector2i.LEFT] == Vector2i(9,6):
					choice_rail = Vector2i(11, 5)
			if rail_address.has(Vector2i.RIGHT):
				if rail_address[Vector2i.RIGHT] == Vector2i(8,6) or rail_address[Vector2i.RIGHT] == Vector2i(10, 5) or rail_address[Vector2i.RIGHT] == Vector2i(9,6):
					choice_rail = Vector2i(9,5)
	tile_map.set_cell(1, tile_pos , 0, choice_rail)
	set_tile_data = Vector2i(7,5)
	mouse_animation.play("LeftClick")

func get_tile_info(tile_pos:Vector2i) -> Dictionary:
	# 次はどうやって曲げるのかいかがいたしましょう
	var tile_info : Dictionary = {
		Vector2i.UP : tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.UP),
		Vector2i.DOWN : tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.DOWN),
		Vector2i.RIGHT: tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.RIGHT),
		Vector2i.LEFT: tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.LEFT),
		# UPLEFT
		Vector2i(-1, -1):tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.UP + Vector2i.LEFT),
		# UPRIGHT
		Vector2i(1, -1):tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.UP + Vector2i.RIGHT),
		# DOWNLEFT
		Vector2i(-1, 1):tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.DOWN + Vector2i.LEFT),
		# DOWNRIGHT
		Vector2i(1, 1):tile_map.get_cell_atlas_coords(1, tile_pos + Vector2i.DOWN + Vector2i.RIGHT)
	}
	return tile_info

func check_tile_info(tile_info : Dictionary):
	for t2 in tile_info.keys():
		match t2:
			Vector2i.UP:
				print("上:" + str(tile_info[t2]))
			Vector2i.DOWN:
				print("下:" + str(tile_info[t2]))
			Vector2i.LEFT:
				print("左:" + str(tile_info[t2]))
			Vector2i.RIGHT:
				print("右:" + str(tile_info[t2]))
			Vector2i(-1, -1):
				print("上左:" + str(tile_info[t2]))
			Vector2i(1, -1):
				print("上右:" + str(tile_info[t2]))
			Vector2i(-1, 1):
				print("下左:" + str(tile_info[t2]))
			Vector2i(1, 1):
				print("下右:" + str(tile_info[t2]))

func _on_player_mouse_entered():
	player_mouse_entered = true

func _on_player_mouse_exited():
	player_mouse_entered = false

func _on_rail_sprite_mouse_entered(viewport, event, shape_idx, sprite : Sprite2D):
	if event.is_action_pressed("click"):
		if tween_finished:
			set_tile_data = sprite.get_meta("AtlasCoodies", Vector2i(-1, -1)) 
			## 次は隣のセルから「これつなげたほうがいいんじゃね？」っていう物を作成していきます。
			## =|| ←　こうなっているときに
			## =」 ←　こんな風に一つのレールにつながるように作成したい。
			pick_up_rails_reverse()
			tween_finished = false
			mouse_animation.play("RightClick")


func _on_rails_sprite_tween_finished():
	tween_finished = true
	for r in rails.get_children():
		r.get_child(0).set_process_unhandled_input(true)

func _on_button_pressed():
	var present = preload("res://Present.tscn").instantiate()
	var start = start_man.position
	var goal = goal.position
	var curve = Curve2D.new()
	curve.bake_interval = 2.0
	## スタートを追加する。
	curve.add_point(start)
	## レールの位置を取得した物
	var rail_address_array = tile_map.get_used_cells(1)
	if rail_address_array.is_empty():
		return
	if rail_address_array[0] * 16 == Vector2i(start):
		return
	## レールの位置に沿って宝箱が移動できるようにしたい。
	for r in rail_address_array:
		## タイルが隣接しているもの同士でなければ追加されないように変更する。
		curve.add_point(r * 16)
	## タイルが隣接していなければゴールへいけないようにしたい。
	present.curve = curve
	add_child(present)
	present.go = true


func _on_goal_clear():
	get_tree().change_scene_to_file(next_scene)
