extends Node2D

var scores: Dictionary = {}
var wall_count: int = 1
var ores_dugs: int = 0

var wall_scene: PackedScene = preload("res://wall.tscn")
var ore_score_scene: PackedScene = preload("res://ore_score_row.tscn")

var current_wall

func _ready():
	create_new_wall()

func _input(event):
	if event is InputEventKey and event.is_pressed() && not event.is_echo():
		if event.keycode == KEY_SPACE:
			cycle_walls()
			
			$ui/wall_count.text = str(wall_count)
		elif event.keycode == KEY_ENTER:
			await RenderingServer.frame_post_draw
			var viewport: Viewport = get_viewport()
			var texture: ViewportTexture = viewport.get_texture()
			texture.get_image().save_png('screenshot.png')
			
func cycle_walls():
	wall_count += 1
		
	current_wall.visible = false # TODO Find way to hide wall and limit raycasting to the specific wall so that walls can be preloaded.
	current_wall.queue_free()
	create_new_wall()
			
func create_new_wall():
	current_wall = wall_scene.instantiate()
	current_wall.with_data(wall_count)
	$wall_container.add_child(current_wall)
	current_wall.ore_cutout.connect(_on_wall_ore_cutout)

func _on_wall_ore_cutout(ore: OreTypes.OreType, wall_reference: int):
	if ore in scores:
		scores[ore].increment_count()
	else:
		var new_ore_score_row = ore_score_scene.instantiate()
		new_ore_score_row.with_data(ore)
		$ui/scores.add_child(new_ore_score_row)
		scores[ore] = new_ore_score_row
	
	if wall_reference == wall_count:
		ores_dugs += 1
		if ores_dugs >= 10:
			cycle_walls()
			ores_dugs = 0
