extends Node2D

var scores = {}
var wall_count = 1

var wall_scene = preload("res://wall.tscn")
var ore_score_scene = preload("res://ore_score_row.tscn")

var current_wall: Node2D

func _ready():
	create_new_wall()

func _input(event):
	if event is InputEventKey and event.is_pressed() && not event.is_echo():
		if event.keycode == KEY_SPACE:
			wall_count += 1
			
			current_wall.free()
			create_new_wall()
			
			$ui/wall_count.text = str(wall_count)
		elif event.keycode == KEY_ENTER:
			await RenderingServer.frame_post_draw
			var viewport = get_viewport()
			var texture = viewport.get_texture()
			texture.get_image().save_png('screenshot.png')
			
func create_new_wall():
	current_wall = wall_scene.instantiate()
	current_wall.with_data(wall_count)
	$wall_container.add_child(current_wall)
	current_wall.ore_cutout.connect(_on_wall_ore_cutout)

func _on_wall_ore_cutout(ore: OreTypes.OreType, _size: int):
	if ore in scores:
		scores[ore].increment_count()
	else:
		var new_ore_score_row = ore_score_scene.instantiate()
		new_ore_score_row.with_data(ore)
		$ui/scores.add_child(new_ore_score_row)
		scores[ore] = new_ore_score_row
