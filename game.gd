extends Node2D

var score = 0
var wall_count = 1

var wall_scene = preload("res://wall.tscn")
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

func _on_wall_ore_cutout(size):
	score += size
	$ui/score_count.text = str(score)
