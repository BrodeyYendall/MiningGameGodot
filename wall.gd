extends Node2D

@export var crack_distance = 300
@export var new_crack_hitbox = 40

var hole_scene = preload("res://hole.tscn")
var crack_scene = preload("res://crack.tscn")
var cutout_scene = preload("res://cutout.tscn")

var cracks = {}
var holes = []  # Stores references to actual hole instances. Vital for crack ray casting
var pathfinder: AStar2D = AStar2D.new()

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() && circle_raycast(event.position).is_empty():
		create_point(event.position)

func create_point(position: Vector2):
	pathfinder.add_point(holes.size(), position)
		
	var new_connections = create_new_cracks(position)
	
	if new_connections.size() >= 2:
		check_for_cycle(new_connections, position)
		
	for new_connection in new_connections:
		pathfinder.connect_points(holes.size(), new_connection)
	
	create_hole_scene(position)
		
func create_new_cracks(new_point_position: Vector2) -> Array[int]:
	var new_connections: Array[int] = []
	for i in range(holes.size()):
		if can_crack_generate(new_point_position, holes[i]):
			var crack_vertices = create_crack_scene(holes[i].position, new_point_position)
			new_connections.append(i)
			
			add_to_crack_map(i, holes.size(), crack_vertices)
			var reversed = crack_vertices.duplicate()
			reversed.reverse()
			add_to_crack_map(holes.size(), i, reversed)
			
	return new_connections
	
func can_crack_generate(start: Vector2, end):
	if end.position.distance_to(start) > crack_distance:
		return false
	
	var query = PhysicsRayQueryParameters2D.new()
	query.set_from(start)
	query.set_to(end.position)
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	# Return true if the object hit is the target circle. This means that nothing else was in the way.
	# We do not exclude the target circle because cutouts attached to it will get in the way
	return result.rid == end.get_rid()
		
			
func check_for_cycle(new_connections: Array[int], new_point: Vector2):
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
		
		var contains_unqiue_points = false
		var path_vectors = PackedVector2Array()
		
		for i in range(1, cycle.size()):
			var current_point = cycle[i]
			if not points_used.has(current_point):
				contains_unqiue_points = true
				points_used[current_point] = true
				
			var prev_point = cycle[i - 1]
			var array_to_append = cracks[prev_point][current_point]
			if i != cycle.size():
				array_to_append = array_to_append.slice(0, -1)
			path_vectors.append_array(array_to_append)
				
				
		if contains_unqiue_points:		
			#print(path_vectors)
			create_cutout_scene(path_vectors)
			
func circle_raycast(position: Vector2, max_results = 1) -> Array:
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(new_crack_hitbox)
	query.set_shape(circle_shape)
	query.transform.origin = position
	
	return get_world_2d().direct_space_state.intersect_shape(query, max_results)
	
func add_to_crack_map(first_id: int, second_id: int, vertices: PackedVector2Array):
	var submap = cracks.get(first_id, {})
	submap[second_id] = vertices
	cracks[first_id] = submap
	
func create_hole_scene(hole_position: Vector2):
	var hole = hole_scene.instantiate()
	hole.position = hole_position
	add_child(hole)
	holes.append(hole)
	
func create_crack_scene(start: Vector2, end: Vector2) -> PackedVector2Array:
	var crack = crack_scene.instantiate()
	var crack_vertices = crack.generate_vertices(start, end)
	add_child(crack)
	return crack_vertices
	
func create_cutout_scene(path_vectors: PackedVector2Array):
	var cutout = cutout_scene.instantiate().with_data(path_vectors)
	add_child(cutout)
