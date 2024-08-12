extends Node2D

@export var crack_distance = 200
@export var new_hole_hitbox = 20

signal generate_background(wall_count: int)
signal cycle_formed(vertices: PackedVector2Array)
signal ore_cutout(size: int)

var hole_scene = preload("res://hole.tscn")
var crack_scene = preload("res://crack.tscn")

var wall_count = 1
var cracks = {}
var holes = []  # Stores references to actual hole instances. Vital for crack ray casting
var pathfinder: AStar2D = AStar2D.new()

func _ready():
	generate_background.emit(wall_count)

func with_data(wall_count: int):
	self.wall_count = wall_count

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && circle_raycast(event.position).is_empty():
		create_point(event.position)

func create_point(position: Vector2):
	pathfinder.add_point(holes.size(), position)
		
	var new_connections = create_new_cracks(position)
	
	if new_connections.size() >= 2:
		check_for_cycle(new_connections[0], new_connections[1], position)
		
	for new_connection in new_connections[0]:
		pathfinder.connect_points(holes.size(), new_connection)
	
	create_hole_scene(position)
	queue_redraw()
		
func create_new_cracks(new_point_position: Vector2) -> Array:
	var new_connections: Array[int] = []
	var new_cracks: Array[SignalingCrack] = []
	
	for i in range(holes.size()):
		if can_crack_generate(new_point_position, holes[i]):
			var crack = create_crack_scene(holes[i].position, new_point_position)
			new_connections.append(i)
			new_cracks.append(crack)
			
			add_to_crack_map(i, holes.size(), crack)
			
	return [new_connections, new_cracks]
	
func can_crack_generate(start: Vector2, end):
	if end.position.distance_to(start) > crack_distance:
		return false
	
	var query = PhysicsRayQueryParameters2D.new()
	query.set_from(start)
	query.set_to(end.position)
	query.set_collide_with_areas(true)
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	# Return true if the object hit is the target circle. This means that nothing else was in the way.
	# We do not exclude the target circle because cutouts attached to it will get in the way
	return result.rid == end.get_rid()
		
			
func check_for_cycle(new_connections: Array[int], new_cracks: Array[SignalingCrack], new_point: Vector2):
	var cycles: Array[PackedInt64Array] = []
	for i in range(new_connections.size()):
		for j in range(i + 1, new_connections.size()):
			var path = pathfinder.get_id_path(new_connections[i], new_connections[j])
			if not path.is_empty():
				cycles.append(path)
				
	cycles.sort_custom(func(a, b): return a.size() < b.size())

	var points_used = {}
	for cycle in cycles:
		cycle.insert(0, holes.size())
		cycle.append(holes.size())
		
		var cycle_centre = calculate_circuit_centre(cycle)
		var contains_unqiue_points = false
		var path_vectors = PackedVector2Array()
		
		for i in range(1, cycle.size()):
			var current_point = cycle[i]
			if not points_used.has(current_point):
				contains_unqiue_points = true
				points_used[current_point] = true
				
			var prev_point = cycle[i - 1]
			var array_to_append = get_from_crack_map(prev_point, current_point, cycle_centre)
			if i != cycle.size():
				array_to_append = array_to_append.slice(0, -1)
			path_vectors.append_array(array_to_append)
					
		if contains_unqiue_points:		
			cycle_formed.emit(path_vectors, new_cracks)
			
func calculate_circuit_centre(cycle: Array[int]) -> Vector2:
	var total = Vector2(0, 0)
	var positions = PackedVector2Array()
	for point in cycle:
		var point_position = pathfinder.get_point_position(point)
		positions.append(point_position)
		total += point_position
	return total / cycle.size()
			
func circle_raycast(position: Vector2, radius = new_hole_hitbox, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(radius)
	query.set_shape(circle_shape)
	query.set_collide_with_areas(true)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
	
func add_to_crack_map(first_id: int, second_id: int, crack: Node2D):
	var submap = cracks.get(first_id, {})
	submap[second_id] = crack
	cracks[first_id] = submap
	
func get_from_crack_map(first_id: int, second_id: int, cutout_centre: Vector2) -> PackedVector2Array:
	var forward = cracks.get(first_id, {}).get(second_id, null)
	if forward == null:
		var backwards = cracks[second_id][first_id].get_nearest_crack_line(cutout_centre)
		backwards.reverse()
		
		return backwards
	return forward.get_nearest_crack_line(cutout_centre)
	
func create_hole_scene(hole_position: Vector2):
	var hole = hole_scene.instantiate()
	hole.position = hole_position
	$hole_holder.add_child(hole)
	holes.append(hole)
	
func create_crack_scene(start: Vector2, end: Vector2) -> Node2D:
	var crack = crack_scene.instantiate()  
	var crack_vertices = crack.generate_vertices(start, end, Constants.CUTOUT_CRACK_CONFIG)
	$crack_holder.add_child(crack)
	return crack
	
func _ore_cutout(ore: OreTypes.OreType, wall_reference: int):
	ore_cutout.emit(ore, wall_reference)
