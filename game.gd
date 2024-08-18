extends Node2D

var scores: Dictionary = {}
var wall_count: int = 1
var ores_dugs: int = 0

var wall_scene: PackedScene = preload("res://wall.tscn")
var ore_score_scene: PackedScene = preload("res://ore_score_row.tscn")

var current_wall: Wall
var next_wall: Wall

func _ready():
	current_wall = create_new_wall(wall_count)
	current_wall.render()
	current_wall.set_process_input(true)
	
	next_wall = create_new_wall(wall_count + 1)
	InputManager.next_wall.connect(_cycle_walls)
			
func _cycle_walls():
	wall_count += 1
	$ui/wall_count.text = str(wall_count)
		
	current_wall.destroy()
	current_wall = next_wall
	current_wall.render()
	current_wall.set_process_input(true)
	next_wall = create_new_wall(wall_count + 1)
			
func create_new_wall(wall_count: int) -> Wall:
	var new_wall = wall_scene.instantiate()
	new_wall.with_data(wall_count)
	$wall_container.add_child(new_wall)
	$wall_container.move_child(new_wall, 0)
	new_wall.ore_cutout.connect(_on_wall_ore_cutout)
	return new_wall

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
			#cycle_walls()
			ores_dugs = 0
