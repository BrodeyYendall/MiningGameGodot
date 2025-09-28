extends Node2D
class_name Wall

@export var crack_distance = 200
@export var new_hole_hitbox = 20
@export var falling_cutout_holder: Node2D

signal generate_background(wall_count: int)
signal cycle_formed(cutout_vecters: PackedVector2Array, new_cracks: Array[SignalingCrack], all_cracks: Array[Crack]) # TODO Makes cracks one argument
signal ore_cutout(ore: OreTypes.OreType, wall_reference: int)

var hole_scene = preload("res://scenes/hole.tscn")
var crack_scene = preload("res://scenes/crack.tscn")

var collision_layer = 0
var wall_count = 1
var cracks = {}
var holes: Dictionary = {}  # Stores references to actual hole instances. Vital for crack ray casting
var hole_count = 0
var pathfinder: AStar2D = AStar2D.new()

func _ready():
	$cutout_queue.falling_cutout_holder = falling_cutout_holder
	print("\nNew wall\n")
	collision_layer = 1 << (wall_count % 8)
	set_collision_layers(self)
	set_process_input(false)
	
	$contents/background.with_data(wall_count)
	
	generate_background.emit(wall_count)
	
func render():
	$contents/background.render()

func set_collision_layers(node):
	for child in node.get_children():
		if child.has_method("set_collision_layer"):
			child.set_collision_layer(collision_layer)
			if child.has_method("set_collision_mask"):
				child.set_collision_mask(collision_layer)
		else:
			set_collision_layers(child)

func with_data(wall_count: int):
	self.wall_count = wall_count

func create_hole(position: Vector2):
	if RaycastHelper.circle_raycast(position, collision_layer, new_hole_hitbox).is_empty():
		print("Hole " + str(hole_count) + " created @ " + str(position))
	
		pathfinder.add_point(hole_count, position)
			
		var new_connections = create_new_cracks(hole_count)
		
		if new_connections.size() >= 2:
			check_for_cycle(new_connections[0], new_connections[1], position)
			
		for new_connection in new_connections[0]:
			pathfinder.connect_points(hole_count, new_connection)
		
		create_hole_scene(position)
		queue_redraw()
	
		
func create_new_cracks(new_point_id: int) -> Array:
	var new_point_position = pathfinder.get_point_position(new_point_id)
	
	var new_connections: Array[int] = []
	var new_cracks: Array[SignalingCrack] = []
	
	for id in holes:
		if can_crack_generate(new_point_position, holes[id]):
			var crack = create_crack_scene(holes[id].position, new_point_position, [id, hole_count])
			new_connections.append(id)
			new_cracks.append(crack)
			
			add_to_crack_map(id, hole_count, crack)
			
	return [new_connections, new_cracks]
	
func can_crack_generate(start: Vector2, end):
	if end.position.distance_to(start) > crack_distance:
		return false
	
	# Return true if the object hit is the target circle. This means that nothing else was in the way.
	# We do not exclude the target circle because cutouts attached to it will get in the way
	return RaycastHelper.line_raycast(start, end.position, collision_layer).rid == end.get_rid()
		
			
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
		cycle.insert(0, hole_count)
		cycle.append(hole_count)
		
		var cycle_centre = calculate_circuit_centre(cycle)
		var contains_unqiue_points = false
		var path_vectors = PackedVector2Array()
		var cracks_in_cycle = []
		
		for i in range(1, cycle.size()):
			var current_point = cycle[i]
			if not points_used.has(current_point):
				contains_unqiue_points = true
				points_used[current_point] = true
				
			var prev_point = cycle[i - 1]
			var crack = get_from_crack_map(prev_point, current_point, cycle_centre)
			cracks_in_cycle.append(crack[0])
			
			var crack_vertices = crack[1]
			if i != crack_vertices.size():
				crack_vertices = crack_vertices.slice(0, -1)
			path_vectors.append_array(crack_vertices)
			
		if contains_unqiue_points:		
			cycle_formed.emit(path_vectors, new_cracks, cracks_in_cycle)
			
func calculate_circuit_centre(cycle: Array[int]) -> Vector2:
	var total = Vector2(0, 0)
	var positions = PackedVector2Array()
	for point in cycle:
		var point_position = pathfinder.get_point_position(point)
		positions.append(point_position)
		total += point_position
	return total / cycle.size()
	
func add_to_crack_map(first_id: int, second_id: int, crack: Crack):
	print("Adding %s -> %s = %s to map" % [first_id, second_id, crack])
	var submap = cracks.get(first_id, {})
	submap[second_id] = crack
	cracks[first_id] = submap
	
func get_from_crack_map(first_id: int, second_id: int, cutout_centre: Vector2) -> Array:
	var forward = cracks.get(first_id, {}).get(second_id, null)
	if forward == null:
		var crack = cracks[second_id][first_id]
		var backwards = crack.get_nearest_crack_line(cutout_centre)
		backwards.reverse()
		
		return [crack, backwards]
	return [forward, forward.get_nearest_crack_line(cutout_centre)]
	
func create_hole_scene(hole_position: Vector2):
	var hole: Hole = hole_scene.instantiate()
	hole.destroy_hole.connect(_destroy_cracks_and_hole)
	hole.with_data(hole_count)
	hole.set_collision_layer(collision_layer)
	hole.set_collision_mask(collision_layer)
	hole.position = hole_position
	$contents/hole_holder.add_child(hole)
	holes[hole_count] = hole
	hole_count += 1
	
func create_crack_scene(start: Vector2, end: Vector2, crack_points: Array[int]) -> Node2D:
	var crack: Crack = crack_scene.instantiate()
	crack.set_collision_layer(collision_layer)
	crack.set_collision_mask(collision_layer)
	crack.generate_vertices(start, end, crack_points, Constants.CUTOUT_CRACK_CONFIG)
	$contents/crack_holder.add_child(crack)
	return crack
	
func _ore_cutout(ore: OreTypes.OreType):
	ore_cutout.emit(ore, wall_count)
	
func destroy():
	$contents.visible = false
	$contents.queue_free()
	$cutout_queue.destroy()

func _destroy_cracks_and_hole(point_id: int):
	for connection in pathfinder.get_point_connections(point_id):
		destroy_crack(connection, point_id)

func destroy_crack(start: int, end: int):
	print("Destroying " + str(start) + " <-> " + str(end))
	pathfinder.disconnect_points(start, end)
	
	if start in cracks:
		var forward = cracks[start]
		if end in forward:
			forward[end].destroy()
			forward.erase(end)
		
	if pathfinder.get_point_connections(start).size() == 0:
		_destroy_point(start)
	else:
		print(str(start) + " connects to " + str(pathfinder.get_point_connections(start)))
		
	if end in cracks:
		var backwards = cracks[end]
		if start in backwards:
			backwards[start].destroy()
			backwards.erase(start)
	if pathfinder.get_point_connections(end).size() == 0:
		print("Can destroy " + str(end))
		_destroy_point(end)
	else:
		print(str(end) + " connects to " + str(pathfinder.get_point_connections(end)))
	
func _destroy_point(point_id: int):
	print("Destroying " + str(point_id))
	cracks.erase(point_id)
	holes[point_id].queue_free()
	holes.erase(point_id)
	pathfinder.remove_point(point_id)
