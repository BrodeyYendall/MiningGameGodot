extends Node2D

@export var wall_queue_size = 4
@export var initial_walls_rendered = 2
@export var cutout_edge_buffer = 15 

var scores: Dictionary = {}
var min_wall_count: int = 1
var ores_dugs: int = 0

var wall_scene: PackedScene = preload("res://scenes/wall.tscn")
var ore_score_scene: PackedScene = preload("res://scenes/ore_score_row.tscn")

var active_walls: Array[Wall]
var wall_queue: Array[Wall]

func _ready():
	for i in range(wall_queue_size):
		wall_queue.append(create_new_wall(i + 1))
	for i in range(initial_walls_rendered):
		activate_next_wall()
	InputManager.next_wall.connect(remove_front_wall)
	InputManager.create_hole.connect(process_create_hole)
	
func activate_next_wall():
	var next_wall: Wall = wall_queue.pop_front()
	next_wall.render()
	next_wall.cycle_formed.connect(_first_cutout_in_wall.bind(next_wall))
	active_walls.append(next_wall)
	wall_queue.append(create_new_wall(wall_queue[-1].wall_count + 1))
	
func remove_front_wall():
	var front_wall = active_walls.pop_front()
	front_wall.destroy()
	activate_next_wall()
	min_wall_count += 1
			
func create_new_wall(wall_count: int) -> Wall:
	var new_wall = wall_scene.instantiate()
	new_wall.with_data(wall_count)
	new_wall.falling_cutout_holder = $falling_cutout_holder
	$wall_container.add_child(new_wall)
	$wall_container.move_child(new_wall, 0)
	return new_wall

func process_create_hole(point: Vector2):
	var objects_on_point = RaycastHelper.circle_raycast(point, 0xFFFFFFFF, 1, 32)
	
	var deepest_cutout = min_wall_count
	for object in objects_on_point:
		if object.collider is Cutout:
			var cutout_wall_count = (object.collider as Cutout).get_parent_wall_count()
			deepest_cutout = max(deepest_cutout, cutout_wall_count + 1)
	var target_wall = deepest_cutout - min_wall_count
	
	if target_wall > 0:
		var objects_on_layer_above = RaycastHelper.circle_raycast(point, active_walls[target_wall - 1].collision_layer, cutout_edge_buffer, 2)
		for object in objects_on_layer_above:
			if not object.collider is Cutout:
				return
	
	active_walls[target_wall].create_hole(point)

func _first_cutout_in_wall(_cutout_vecters, _new_cracks, _all_cracks, wall: Wall):
	wall.cycle_formed.disconnect(_first_cutout_in_wall)
	activate_next_wall()
