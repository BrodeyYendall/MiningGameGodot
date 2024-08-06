extends Node2D

var scores = {}
var wall_count = 1

var wall_scene = preload("res://wall.tscn")
var ore_score_scene = preload("res://ore_score_row.tscn")

var current_wall: Node2D

func _ready():
	current_wall = $wall_container/wall

func _input(event):
	if event is InputEventKey and event.is_pressed() && not event.is_echo():
		if event.keycode == KEY_SPACE:
			create_new_wall()
			wall_count += 1
			$ui/wall_count.text = str(wall_count)
		elif event.keycode == KEY_ENTER:
			await RenderingServer.frame_post_draw
			var viewport = get_viewport()
			var texture = viewport.get_texture()
			texture.get_image().save_png('screenshot.png')
			
func create_new_wall():
	current_wall.queue_free()
	current_wall = wall_scene.instantiate()
	$wall_container.add_child(current_wall)
	current_wall.ore_cutout.connect(_on_wall_ore_cutout)

func _on_wall_ore_cutout(ore: OreTypes.OreType, size: int):
	var score_for_size = adjust_score(ore, size)
	
	if ore in scores:
		scores[ore].increment_count(score_for_size)
	else:
		var new_ore_score_row = ore_score_scene.instantiate()
		new_ore_score_row.with_data(ore, score_for_size)
		$ui/scores.add_child(new_ore_score_row)
		scores[ore] = new_ore_score_row
		
func adjust_score(ore: OreTypes.OreType, size: int) -> float:
	return round_num(size / 300.0, 2)

func round_num(num: float, places: int):
	return (round(num*pow(10.0,places))/pow(10.0,places))
